*> The client side of the protocol, entering a world (docs/protocol/05a, 06): Login and Respawn read
*> (PLAY-LOGIN-READ, PLAY-RESPAWN-READ: the dimension the server names) and DIMENSION-ENTER (the dimension's height
*> range and sky light from the dimension_type registry, the replica emptied, the world screen shown). Chunks
*> themselves are decoded by REPLICA-CHUNK-LOAD (world-replica.cob, both the 001 and the 24-section forms).
*> Split from protocol-client.cob (T2944).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-LOGIN-READ.
*> USING CLIENT-STATE, packet (play Login, 05a 0x32): the player's entity id, the dimension names
*> (every dimension the server has, the first CL-MAX-LEVELS kept), view distance, the
*> dimension and its type's height range and sky light (from the dimension_type registry), the game
*> mode (health 20 until Set Health); the dimension is entered (DIMENSION-ENTER) and the entity
*> replica and player list emptied.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-VALUE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-INT" USING PB-BUFFER PL-ENTITY-ID
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-VALUE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     MOVE 0 TO PL-LEVEL-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
         MOVE SPACES TO WS-NAME
         CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-NAME WS-CAP WS-LENGTH
         IF PL-LEVEL-COUNT < CL-MAX-LEVELS
             ADD 1 TO PL-LEVEL-COUNT
             MOVE WS-NAME TO PL-LEVEL(PL-LEVEL-COUNT)
         END-IF
     END-PERFORM
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
     CALL "PB-GET-VARINT" USING PB-BUFFER PL-VIEW-DISTANCE
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-VALUE
     PERFORM 3 TIMES
         CALL "PB-GET-BOOL" USING PB-BUFFER WS-VALUE
     END-PERFORM
     CALL "PB-GET-VARINT" USING PB-BUFFER PL-DIM-TYPE
     MOVE SPACES TO PL-DIM-NAME
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER PL-DIM-NAME WS-CAP WS-LENGTH
     CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
     CALL "PB-GET-VARINT" USING PB-BUFFER PL-MODE
     MOVE 20 TO PL-HEALTH
     CALL "DIMENSION-ENTER" USING CLIENT-STATE
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     GOBACK.
 END PROGRAM PLAY-LOGIN-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAY-RESPAWN-READ.
*> USING CLIENT-STATE, packet (Respawn, 05b 0x54: CommonPlayerSpawnInfo, data to keep): the
*> dimension, its type and the game mode; the dimension is entered (a respawn after death and
*> travel alike: the old dimension's replica and meshes are dropped, the new type's height range
*> and sky light taken) and the entities seen are forgotten (the server adds them again; the
*> player list stays). Inventory, health and food are kept until the server says otherwise
*> (standin-content §15.5: travel keeps them).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-CAP                 BINARY-LONG VALUE 64.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 LINKAGE SECTION.
 COPY CLSTATE.
 COPY PROTO.
 PROCEDURE DIVISION USING CLIENT-STATE PB-BUFFER.
     CALL "PB-GET-VARINT" USING PB-BUFFER PL-DIM-TYPE
     MOVE SPACES TO PL-DIM-NAME
     CALL "PB-GET-IDENTIFIER" USING PB-BUFFER PL-DIM-NAME WS-CAP WS-LENGTH
     CALL "PB-GET-LONG" USING PB-BUFFER WS-LONG
     CALL "PB-GET-VARINT" USING PB-BUFFER PL-MODE
     CALL "DIMENSION-ENTER" USING CLIENT-STATE
     CALL "ENTITIES-FORGET" USING CLIENT-STATE
     GOBACK.
 END PROGRAM PLAY-RESPAWN-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. DIMENSION-ENTER.
*> USING CLIENT-STATE (PL-DIM-TYPE set): the type's height range and sky light from the
*> dimension_type registry (else 0, 256 and sky light), not loaded or positioned yet, no fall
*> under way, no hurt indication, not sprinting or eating; the replica is emptied and the world
*> screen shown.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-D                   BINARY-LONG.
 01 WS-SCREEN              BINARY-LONG VALUE SCR-WORLD.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO PL-MIN-Y PL-LOADED PL-POSITIONED PL-BATCHES PL-VY PL-HURT-UNTIL
     MOVE 0 TO PL-SPRINTING PL-EATING
     MOVE 256 TO PL-HEIGHT
     MOVE 1 TO PL-HAS-SKY
     COMPUTE WS-D = PL-DIM-TYPE + 1
     IF WS-D >= 1 AND WS-D <= RG-DIM-COUNT
         MOVE RG-DIM-MIN-Y(WS-D) TO PL-MIN-Y
         MOVE RG-DIM-HEIGHT(WS-D) TO PL-HEIGHT
         MOVE RG-DIM-HAS-SKY(WS-D) TO PL-HAS-SKY
     END-IF
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     GOBACK.
 END PROGRAM DIMENSION-ENTER.
