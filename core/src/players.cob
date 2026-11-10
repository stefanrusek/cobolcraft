*> Player table (data-model §6). Rows live in CORE-PLAYERS (core/copy/CORESTATE.cpy); a player row
*> exists from the accepted login until the connection is released.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-CREATE.
*> USING connection id, name (PIC X(16)), name length, offline UUID (PIC X(16)), player row out
*> (BINARY-LONG; 0 when the table is full). A new player: the world spawn point facing its yaw
*> (standin §5.2), the game mode of the settings (FR-007, FR-009; a guest of a world opened to
*> others gets the guest mode, FR-017), full health 20, food 20 and saturation 5.0 (17 section 4.9), a new entity id, held
*> slot 0, an empty inventory, state Joining. Operator status: ACCESS-OPERATOR-STATUS
*> (core/src/access.cob: the operator list, the host, allowed guests). In a world
*> hosted by the client (host kinds 1 and 2) new players get the world's GameMode (CW-GAME-MODE,
*> level.dat; guests the guest mode). A UUID not yet known is looked up in the world's player
*> files (PLAYER-DAT-READ: load on join). A known player whose state is stored (KN-STORED) gets back
*> its game mode, health, food, held slot and inventory (FR-014). A player whose
*> UUID has not been in the world before (CORE-KNOWN) becomes known; when it is in survival it is
*> given the starting inventory of standin §2 (ITEMS.cpy START-ITEM-TABLE; US4-8), once. A known
*> player who left while dead (KN-DEATH-CAUSE > 0, standin §10.6) is dead again: survival, health 0,
*> the same death cause and killer (Player Loaded then makes it Dead, PLAY-JOIN shows the death
*> screen). A known player who left from a place (KN-PLACED) is put back there (PLAYER-PLACE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 COPY RULES.
 COPY CITEMS.
 COPY STARTKIT.
 01 WS-ROW                 BINARY-LONG.
 01 WS-HOST                PIC 9.
 01 WS-KNOWN               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY COREAPI.
 01 L-CONN                 BINARY-LONG.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-CONN L-NAME L-NAME-LENGTH L-UUID L-ROW.
     SET ADDRESS OF CORE-SETTINGS TO ADDRESS OF CW-SETTINGS
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS OR L-ROW > 0
         IF PL-USED(WS-ROW) NOT = 1
             MOVE WS-ROW TO L-ROW
         END-IF
     END-PERFORM
     IF L-ROW > 0
         INITIALIZE PL-ENTRY(L-ROW) MN-ENTRY(L-ROW)
         MOVE 1 TO PL-USED(L-ROW)
         MOVE L-CONN TO PL-CONN(L-ROW)
         MOVE L-ROW TO CN-PLAYER(L-CONN)
         MOVE L-NAME TO PL-NAME(L-ROW)
         MOVE L-NAME-LENGTH TO PL-NAME-LENGTH(L-ROW)
         MOVE L-UUID TO PL-UUID(L-ROW)
         CALL "ENTITY-NEW-ID" USING PL-ENTITY-ID(L-ROW)
         MOVE PS-JOINING TO PL-STATE(L-ROW)
         MOVE CW-DIM(1) TO PL-DIM(L-ROW)
         MOVE CW-SPAWN-X TO PL-X(L-ROW)
         MOVE CW-SPAWN-Y TO PL-Y(L-ROW) PL-FALL-START(L-ROW)
         MOVE CW-SPAWN-Z TO PL-Z(L-ROW)
         MOVE CW-SPAWN-YAW TO PL-YAW(L-ROW)
         MOVE 0 TO PL-PITCH(L-ROW)
         MOVE 1 TO PL-ON-GROUND(L-ROW)
         MOVE 0 TO WS-HOST
         IF CS-HOST-KIND > 0 AND L-NAME = CS-HOST-NAME
             MOVE 1 TO WS-HOST
         END-IF
         MOVE CS-DEFAULT-MODE TO PL-MODE(L-ROW)
         IF CS-HOST-KIND > 0
             MOVE CW-GAME-MODE TO PL-MODE(L-ROW)
         END-IF
         IF CS-HOST-KIND = 2 AND WS-HOST = 0
             MOVE CS-GUEST-MODE TO PL-MODE(L-ROW)
         END-IF
         CALL "ACCESS-OPERATOR-STATUS" USING L-ROW
         MOVE RULE-MAX-HEALTH TO PL-HEALTH(L-ROW)
         MOVE RULE-MAX-FOOD TO PL-FOOD(L-ROW)
         MOVE RULE-START-SATURATION TO PL-SATURATION(L-ROW)
         MOVE CS-VIEW-DISTANCE TO PL-VIEW-DISTANCE(L-ROW)
         COMPUTE PL-CENTER-X(L-ROW) = FUNCTION INTEGER(PL-X(L-ROW) / 16)
         COMPUTE PL-CENTER-Z(L-ROW) = FUNCTION INTEGER(PL-Z(L-ROW) / 16)
         MOVE -1 TO PL-BREAK-STAGE(L-ROW)
         MOVE 0 TO WS-KNOWN
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KN-COUNT
             IF KN-UUID(WS-I) = L-UUID
                 MOVE WS-I TO WS-KNOWN
             END-IF
         END-PERFORM
         IF WS-KNOWN = 0
             CALL "PLAYER-DAT-READ" USING L-UUID WS-KNOWN
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KN-COUNT
             IF KN-UUID(WS-I) = L-UUID
                 IF KN-STORED(WS-I) = 1
                     MOVE KN-MODE(WS-I) TO PL-MODE(L-ROW)
                     MOVE KN-HEALTH(WS-I) TO PL-HEALTH(L-ROW)
                     MOVE KN-FOOD(WS-I) TO PL-FOOD(L-ROW)
                     COMPUTE PL-SATURATION(L-ROW) = FUNCTION MIN(PL-SATURATION(L-ROW), PL-FOOD(L-ROW))
                     MOVE KN-HELD(WS-I) TO PL-HELD(L-ROW)
                     MOVE KN-INVENTORY(WS-I) TO PL-INVENTORY(L-ROW)
                     CALL "KX-FETCH" USING L-ROW WS-I
                     COMPUTE PL-SATURATION(L-ROW) = FUNCTION MIN(PL-SATURATION(L-ROW), PL-FOOD(L-ROW))
                 END-IF
                 IF KN-DEATH-CAUSE(WS-I) > 0
                     MOVE 0 TO PL-MODE(L-ROW) PL-HEALTH(L-ROW)
                     MOVE KN-DEATH-CAUSE(WS-I) TO PL-DEATH-CAUSE(L-ROW)
                     MOVE KN-KILLER-NAME(WS-I) TO PL-KILLER-NAME(L-ROW)
                     MOVE KN-KILLER-LENGTH(WS-I) TO PL-KILLER-LENGTH(L-ROW)
                 END-IF
                 IF KN-PLACED(WS-I) = 1
                     CALL "PLAYER-PLACE" USING L-ROW WS-I
                 END-IF
             END-IF
         END-PERFORM
         IF WS-KNOWN = 0 AND PL-MODE(L-ROW) = 0
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > START-ITEM-COUNT
                 MOVE SI-ITEM(WS-I) TO PL-SLOT-ITEM(L-ROW, SI-SLOT(WS-I) + 1)
                 MOVE SI-COUNT(WS-I) TO PL-SLOT-COUNT(L-ROW, SI-SLOT(WS-I) + 1)
             END-PERFORM
         END-IF
         IF WS-KNOWN = 0 AND KN-COUNT < CORE-MAX-KNOWN
             ADD 1 TO KN-COUNT
             MOVE L-UUID TO KN-UUID(KN-COUNT)
             MOVE 0 TO KN-DEATH-CAUSE(KN-COUNT)
             INITIALIZE KN-PLACE(KN-COUNT) KN-STATE(KN-COUNT)
             CALL "KX-ROW-FREE" USING KN-COUNT
         END-IF
     END-IF
     GOBACK.
 END PROGRAM PLAYER-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-PLACE.
*> USING player row, known-player row (BINARY-LONG): when the dimension the player left from is
*> enabled (one of CW-DIM), the player is in it at the stored position and facing (US12-3);
*> otherwise it stays at the world spawn point in cobolcraft:main (standin §15.5, US12-4).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-D                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 01 L-KNOWN                BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW L-KNOWN.
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         IF CW-DIM(WS-D) = KN-DIM(L-KNOWN)
             MOVE KN-DIM(L-KNOWN) TO PL-DIM(L-ROW)
             MOVE KN-X(L-KNOWN) TO PL-X(L-ROW)
             MOVE KN-Y(L-KNOWN) TO PL-Y(L-ROW) PL-FALL-START(L-ROW)
             MOVE KN-Z(L-KNOWN) TO PL-Z(L-ROW)
             MOVE KN-YAW(L-KNOWN) TO PL-YAW(L-ROW)
             MOVE KN-PITCH(L-KNOWN) TO PL-PITCH(L-ROW)
             COMPUTE PL-CENTER-X(L-ROW) = FUNCTION INTEGER(PL-X(L-ROW) / 16)
             COMPUTE PL-CENTER-Z(L-ROW) = FUNCTION INTEGER(PL-Z(L-ROW) / 16)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PLAYER-PLACE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-FIND-NAME.
*> USING name (PIC X(16)), name length, player row out (0 = no player with that name).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-NAME-LENGTH L-ROW.
     MOVE 0 TO L-ROW
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS OR L-ROW > 0
         IF PL-USED(WS-ROW) = 1 AND PL-NAME-LENGTH(WS-ROW) = L-NAME-LENGTH
                 AND PL-NAME(WS-ROW) = L-NAME
             MOVE WS-ROW TO L-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PLAYER-FIND-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-LEAVE.
*> USING player row: the player leaves the world (OTHERS-LEAVE: the other players are told); the
*> row is free again and its connection no longer has a player. The row is copied first: a caller may pass CN-PLAYER itself.
*> The cursor stack and the grids go back into the inventory first (MENU-RELEASE), then its known-player row keeps its
*> state (PLAYER-REMEMBER).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-BACK                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     CALL "MENU-RELEASE" USING WS-ROW WS-BACK
     CALL "PLAYER-REMEMBER" USING WS-ROW
     CALL "OTHERS-LEAVE" USING WS-ROW
     IF PL-CONN(WS-ROW) > 0
         MOVE 0 TO CN-PLAYER(PL-CONN(WS-ROW))
     END-IF
     INITIALIZE PL-ENTRY(WS-ROW) MN-ENTRY(WS-ROW)
     GOBACK.
 END PROGRAM PLAYER-LEAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYERS-ONLINE.
*> USING count out (BINARY-LONG): players in the world, that is player rows whose connection has
*> reached the play phase.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1
             IF CN-PHASE(PL-CONN(WS-ROW)) = PH-PLAY
                 ADD 1 TO L-COUNT
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PLAYERS-ONLINE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PLAYER-REMEMBER.
*> USING player row: its known-player row keeps the player's state (FR-014; data-model §6 "state
*> stored"): whether it is dead, with the death cause and killer (standin §10.6); the dimension,
*> position and facing (KN-PLACED, US12-3); name, game mode, health, food, held slot and inventory
*> (KN-STORED); and it is marked to be written by the next world save (KN-DIRTY).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-ROW.
     MOVE L-ROW TO WS-ROW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KN-COUNT
         IF KN-UUID(WS-I) = PL-UUID(WS-ROW)
             MOVE PL-DEATH-CAUSE(WS-ROW) TO KN-DEATH-CAUSE(WS-I)
             MOVE PL-KILLER-NAME(WS-ROW) TO KN-KILLER-NAME(WS-I)
             MOVE PL-KILLER-LENGTH(WS-ROW) TO KN-KILLER-LENGTH(WS-I)
             MOVE 1 TO KN-PLACED(WS-I) KN-STORED(WS-I) KN-DIRTY(WS-I)
             MOVE PL-DIM(WS-ROW) TO KN-DIM(WS-I)
             MOVE PL-X(WS-ROW) TO KN-X(WS-I)
             MOVE PL-Y(WS-ROW) TO KN-Y(WS-I)
             MOVE PL-Z(WS-ROW) TO KN-Z(WS-I)
             MOVE PL-YAW(WS-ROW) TO KN-YAW(WS-I)
             MOVE PL-PITCH(WS-ROW) TO KN-PITCH(WS-I)
             MOVE PL-NAME(WS-ROW) TO KN-NAME(WS-I)
             MOVE PL-NAME-LENGTH(WS-ROW) TO KN-NAME-LENGTH(WS-I)
             MOVE PL-MODE(WS-ROW) TO KN-MODE(WS-I)
             MOVE PL-HEALTH(WS-ROW) TO KN-HEALTH(WS-I)
             MOVE PL-FOOD(WS-ROW) TO KN-FOOD(WS-I)
             MOVE PL-HELD(WS-ROW) TO KN-HELD(WS-I)
             MOVE PL-INVENTORY(WS-ROW) TO KN-INVENTORY(WS-I)
             CALL "KX-STORE" USING WS-ROW WS-I
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PLAYER-REMEMBER.
