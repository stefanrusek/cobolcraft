*> Convergence acceptance tests of US4-7, its edge case of simultaneous changes and SC-002 for
*> block changes (spec.md US4; standin-content §1.3): two Players in one world (Alice hosts the
*> single-player world, Bobby joins over a further memory connection of the same core), Alice at the
*> spawn point (4.5, 54, 8.5) facing east, Bobby two blocks south of her. Each breaks, places or toggles blocks with the client's
*> controls; the other Player's client replica shows the same change, and both replicas end equal to
*> the world (the core) after changes to one block in the same frame.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-SHARED-CHANGES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us4-shared".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 21.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Shared".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-WHO                 BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-JOINED2             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-FX                  FLOAT-SHORT VALUE 0.
 01 WS-FY                  FLOAT-SHORT VALUE 0.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-CORE                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-A-STATE             BINARY-LONG.
 01 WS-B-STATE             BINARY-LONG.
 01 WS-B-LIGHT             BINARY-LONG.
 01 WS-CELLS               BINARY-LONG.
 01 WS-DIFF                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-BOBBY
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED2
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
*>   Bobby walks two blocks south (D, facing east) so that neither stands in the other's aim.
     MOVE CC-KEY-D TO WS-KEY
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-KIND
     MOVE 9 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-EV-KEY-UP TO WS-KIND
     CALL "CV-KEY-SET" USING CONVH WS-BOBBY WS-KEY WS-KIND
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

*>   Alice places greystone (slot 0) on the turf top (6, 53, 8).
     MOVE WS-ALICE TO WS-WHO
     MOVE 6.5 TO WS-TX
     MOVE 53.95 TO WS-TY
     MOVE 8.5 TO WS-TZ
     PERFORM AIM-WHO
     PERFORM USE-WHO
     MOVE 6 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM CELL-ALL
     MOVE "acceptance US4-7 given two Players are connected when one places a block within the "
         & "other's view distance then the other Player sees the same change" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "joined 1 1 core 2 placer 2 other 2" TO TL-EXPECTED
     PERFORM OBSERVE-ALL
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Alice places a glowtube (key 7) on the turf top (5, 53, 7); Bobby toggles it with his pry_bar
*>   (key 9, not a block item).
     MOVE CC-KEY-7 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5.5 TO WS-TX
     MOVE 53.95 TO WS-TY
     MOVE 7.5 TO WS-TZ
     PERFORM AIM-WHO
     PERFORM USE-WHO
     MOVE WS-BOBBY TO WS-WHO
     MOVE CC-KEY-9 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-BOBBY WS-KEY
     MOVE 5.5 TO WS-TX
     MOVE 54.5 TO WS-TY
     MOVE 7.5 TO WS-TZ
     PERFORM AIM-WHO
     PERFORM USE-WHO
     MOVE 5 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 7 TO WS-Z
     PERFORM CELL-ALL
     MOVE 55 TO WS-Y
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-LIGHT
     MOVE "acceptance US4-7 given two Players are connected when one toggles a glowtube the other "
         & "placed then the other Player sees it unlit and its light gone" TO TL-CASE
     MOVE "joined 1 1 core 14 placer 14 other 14 light 7" TO TL-EXPECTED
     PERFORM OBSERVE-ALL
     MOVE WS-LIGHT TO WS-E1
     STRING " light " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Bobby breaks Alice's greystone with his pry_bar (a quarter of 1.5 s): Alice sees it go.
     MOVE 6.5 TO WS-TX
     MOVE 54.5 TO WS-TY
     MOVE 8.5 TO WS-TZ
     PERFORM AIM-WHO
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-BOBBY WS-BUTTON WS-KIND
     MOVE 12 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-BOBBY WS-BUTTON WS-KIND
     CALL "CV-STEP" USING CONVH
     MOVE 6 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM CELL-ALL
     MOVE "acceptance US4-7 given two Players are connected when one breaks a block then the "
         & "other Player sees it gone" TO TL-CASE
     MOVE "joined 1 1 core 0 placer 0 other 0" TO TL-EXPECTED
     PERFORM OBSERVE-ALL
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US4 edge: both place on the same turf top in the same frame (Alice greystone, Bobby
*>   cardstack): both clients end with the block the world kept.
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-KEY-1 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE CC-KEY-5 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-BOBBY WS-KEY
     MOVE 6.5 TO WS-TX
     MOVE 53.95 TO WS-TY
     MOVE 8.5 TO WS-TZ
     MOVE WS-ALICE TO WS-WHO
     PERFORM AIM-WHO
     MOVE WS-BOBBY TO WS-WHO
     PERFORM AIM-WHO
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-FX = IN-WIN-W / 2
     COMPUTE WS-FY = IN-WIN-H / 2
     CALL "CV-QUEUE" USING CONVH WS-ALICE WS-KIND WS-BUTTON WS-FX WS-FY
     CALL "CV-QUEUE" USING CONVH WS-BOBBY WS-KIND WS-BUTTON WS-FX WS-FY
     CALL "CV-STEP" USING CONVH
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-QUEUE" USING CONVH WS-ALICE WS-KIND WS-BUTTON WS-FX WS-FY
     CALL "CV-QUEUE" USING CONVH WS-BOBBY WS-KIND WS-BUTTON WS-FX WS-FY
     CALL "CV-STEP" USING CONVH
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 54 TO WS-Y
     PERFORM CELL-ALL
     MOVE "US4 edge given two Players when both place a block at the same position in the same "
         & "frame then both end with the same block, the one the world kept" TO TL-CASE
     MOVE "same 1 kept a block 1" TO TL-EXPECTED
     MOVE 0 TO WS-E1 WS-E2
     IF WS-A-STATE = WS-CORE AND WS-B-STATE = WS-CORE
         MOVE 1 TO WS-E1
     END-IF
     IF WS-CORE = 2 OR WS-CORE = 9
         MOVE 1 TO WS-E2
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "same " FUNCTION TRIM(WS-E1) " kept a block " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     IF WS-E1 NOT = "         1"
         MOVE WS-CORE TO WS-E1
         MOVE WS-A-STATE TO WS-E2
         MOVE WS-B-STATE TO WS-E3
         STRING TL-OBSERVED DELIMITED BY "  " " (core " FUNCTION TRIM(WS-E1) " Alice "
             FUNCTION TRIM(WS-E2) " Bobby " FUNCTION TRIM(WS-E3) ")" DELIMITED BY SIZE
             INTO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   SC-002 (block changes): every cell around the changes is the same in the world and in both
*>   replicas.
     MOVE 0 TO WS-CELLS WS-DIFF
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 12
         PERFORM VARYING WS-Y FROM 48 BY 1 UNTIL WS-Y > 62
             PERFORM VARYING WS-Z FROM 2 BY 1 UNTIL WS-Z > 14
                 PERFORM CELL-ALL
                 ADD 1 TO WS-CELLS
                 IF WS-A-STATE NOT = WS-CORE OR WS-B-STATE NOT = WS-CORE
                     ADD 1 TO WS-DIFF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "SC-002 given two Players in the same dimension when they have broken, placed and "
         & "toggled blocks then every block change is seen identically by both: 2535 cells around "
         & "the changes equal the world in both replicas" TO TL-CASE
     MOVE "cells 2535 different 0" TO TL-EXPECTED
     MOVE WS-CELLS TO WS-E1
     MOVE WS-DIFF TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "cells " FUNCTION TRIM(WS-E1) " different " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 AIM-WHO.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-WHO)
     CALL "AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ.

 USE-WHO.
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-WHO WS-BUTTON WS-KIND
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-BUTTON-SET" USING CONVH WS-WHO WS-BUTTON WS-KIND
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.

*>   The cell WS-X, WS-Y, WS-Z in the world and both replicas; Bobby's block light.
 CELL-ALL.
     CALL "CORE-BLOCK" USING WS-X WS-Y WS-Z WS-CORE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-A-STATE WS-SKY WS-LIGHT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-B-STATE WS-SKY WS-B-LIGHT.

*>   "joined <a> <b> core <s> placer <s> other <s>": the acting Player's replica, then the other's.
 OBSERVE-ALL.
     MOVE WS-JOINED TO WS-E1
     MOVE WS-JOINED2 TO WS-E2
     MOVE WS-CORE TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "joined " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2) " core " FUNCTION TRIM(WS-E3)
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     IF WS-WHO = WS-ALICE
         MOVE WS-A-STATE TO WS-E1
         MOVE WS-B-STATE TO WS-E2
     ELSE
         MOVE WS-B-STATE TO WS-E1
         MOVE WS-A-STATE TO WS-E2
     END-IF
     STRING " placer " FUNCTION TRIM(WS-E1) " other " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED WITH POINTER WS-PTR.
 END PROGRAM ACC-US4-SHARED-CHANGES.

*> Test helpers (test infrastructure).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. AIM-AT.
*> USING CLIENT-STATE, target x, y, z (FLOAT-LONG): the local player looks from the eye (feet + 1.6)
*> at that point (yaw 0 faces +Z, 90 faces -X; positive pitch looks down).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-H                   FLOAT-LONG.
 01 WS-A                   FLOAT-LONG.
 01 WS-NX                  FLOAT-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-X L-Y L-Z.
     COMPUTE WS-DX = L-X - PL-X
     COMPUTE WS-DY = L-Y - PL-Y - 1.6
     COMPUTE WS-DZ = L-Z - PL-Z
     COMPUTE WS-NX = 0 - WS-DX
     CALL "ATAN2-DEG" USING WS-NX WS-DZ WS-A
     MOVE WS-A TO PL-YAW
     COMPUTE WS-H = FUNCTION SQRT(WS-DX * WS-DX + WS-DZ * WS-DZ)
     CALL "ATAN2-DEG" USING WS-DY WS-H WS-A
     COMPUTE PL-PITCH = 0 - WS-A
     GOBACK.
 END PROGRAM AIM-AT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ATAN2-DEG.
*> USING y, x, angle out (FLOAT-LONG, degrees, -180 to 180).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-A                   FLOAT-LONG.
 LINKAGE SECTION.
 01 L-Y                    FLOAT-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-A                    FLOAT-LONG.
 PROCEDURE DIVISION USING L-Y L-X L-A.
     EVALUATE TRUE
         WHEN L-X > 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X)
         WHEN L-X < 0 AND L-Y >= 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) + FUNCTION PI
         WHEN L-X < 0
             COMPUTE WS-A = FUNCTION ATAN(L-Y / L-X) - FUNCTION PI
         WHEN L-Y > 0
             COMPUTE WS-A = FUNCTION PI / 2
         WHEN L-Y < 0
             COMPUTE WS-A = 0 - FUNCTION PI / 2
         WHEN OTHER
             MOVE 0 TO WS-A
     END-EVALUATE
     COMPUTE L-A = WS-A * 180 / FUNCTION PI
     GOBACK.
 END PROGRAM ATAN2-DEG.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. COUNT-GROUND.
*> USING CLIENT-STATE, item, count out: the ground items (loose_item, type 1) of that item in the
*> client's entity replica.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ITEM                 BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ITEM L-COUNT.
     MOVE 0 TO L-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = 1 AND EN-STACK-ITEM(WS-I) = L-ITEM
             ADD 1 TO L-COUNT
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM COUNT-GROUND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-BLOCK.
*> USING x, y, z, state out: the block of the world's main dimension (the core).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-STATE.
     CALL "WORLD-GET-BLOCK" USING WS-DIM L-X L-Y L-Z L-STATE
     GOBACK.
 END PROGRAM CORE-BLOCK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-PLAYER-SLOTS.
*> USING name (PIC X(16)), held out, text out (PIC X(1024)): the world's record of that online
*> player: held slot and non-empty slots as "<slot>:<count>x<item>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-P                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-HELD                 BINARY-LONG.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-NAME L-HELD L-TEXT.
     MOVE 0 TO WS-P
     MOVE -1 TO L-HELD
     MOVE "none" TO L-TEXT
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64 OR WS-P > 0
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = L-NAME
             MOVE WS-R TO WS-P
         END-IF
     END-PERFORM
     IF WS-P > 0
         MOVE PL-HELD(WS-P) TO L-HELD
         MOVE SPACES TO L-TEXT
         MOVE 1 TO WS-PTR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
             IF PL-SLOT-COUNT(WS-P, WS-I) > 0
                 COMPUTE WS-E1 = WS-I - 1
                 MOVE PL-SLOT-COUNT(WS-P, WS-I) TO WS-E2
                 MOVE PL-SLOT-ITEM(WS-P, WS-I) TO WS-E3
                 IF WS-PTR > 1
                     STRING " " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
                 END-IF
                 STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
                     DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
             END-IF
         END-PERFORM
     END-IF
     GOBACK.
 END PROGRAM CORE-PLAYER-SLOTS.
