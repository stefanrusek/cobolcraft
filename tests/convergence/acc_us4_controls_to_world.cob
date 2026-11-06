*> Convergence acceptance tests of US4-2, US4-3, US4-4, US4-5, US4-6 and US4-8 (spec.md US4;
*> standin-content §1.1 break times, §1.3 placement and use, §2 starting inventory and tools): a
*> Player in a single-player world (the client's in-process core over a memory connection) uses
*> the client's controls (hotbar keys, the place and break buttons aimed at blocks, the inventory
*> screen), and the world itself (the core) and the client's replica show the outcome.
*> Spawn (4.5, 54, 8.5) facing east; turf tops: (6, 53, 8), (5, 53, 7).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US4-CONTROLS-TO-WORLD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us4-controls".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Controls".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 8.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-ARG                 BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-TX                  FLOAT-LONG.
 01 WS-TY                  FLOAT-LONG.
 01 WS-TZ                  FLOAT-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-CORE                BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-LIGHT               BINARY-LONG.
 01 WS-HELD                BINARY-LONG.
 01 WS-ITEMS               BINARY-LONG.
 01 WS-ITEMS0              BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-TEXT2               PIC X(1024).
 01 WS-SAY                 PIC X(64).
 01 WS-SAY-LENGTH          BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

*>   US4-8: the starting items, as the client's inventory shows them and as the world holds them.
     PERFORM CLIENT-SLOTS
     CALL "CORE-PLAYER-SLOTS" USING WS-NAME WS-HELD WS-TEXT2
     MOVE "acceptance US4-8 given a first-time Player in survival mode when they join then their "
         & "inventory holds the starting items (items 2 to 9 x64 in slots 0 to 7, a pry_bar, a "
         & "trowel), held slot 0" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "client 0:64x2 1:64x3 2:64x4 3:64x5 4:64x6 5:64x7 6:64x8 7:64x9 8:1x10 9:1x11 held 0 "
         & "| core 0:64x2 1:64x3 2:64x4 3:64x5 4:64x6 5:64x7 6:64x8 7:64x9 8:1x10 9:1x11 held 0"
         TO TL-EXPECTED
     MOVE WS-HELD TO WS-E2
     MOVE PL-HELD TO WS-E1
     MOVE SPACES TO TL-OBSERVED
     STRING "client " FUNCTION TRIM(WS-TEXT) " held " FUNCTION TRIM(WS-E1) " | core "
         FUNCTION TRIM(WS-TEXT2) " held " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US4-2: greystone (slot 0) placed on the turf top at (6, 53, 8).
     MOVE 6.5 TO WS-TX
     MOVE 53.95 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 6 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM BLOCK-BOTH
     MOVE "acceptance US4-2 given the Player holds greystone and aims at the top face of turf when "
         & "they use the place control then greystone appears in the empty position above it"
         TO TL-CASE
     MOVE "core 2 client 2" TO TL-EXPECTED
     PERFORM BOTH-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Cardstack (key 5: slot 4) on top of that greystone: axis y; then against its west face: axis x.
     MOVE CC-KEY-5 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 6.5 TO WS-TX
     MOVE 54.95 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 55 TO WS-Y
     PERFORM BLOCK-BOTH
     MOVE "acceptance US4-2 given the Player holds cardstack and aims at a top face when they use "
         & "the place control then a cardstack with axis y (state 9) appears above it" TO TL-CASE
     MOVE "core 9 client 9" TO TL-EXPECTED
     PERFORM BOTH-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE 6.0 TO WS-TX
     MOVE 54.5 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 5 TO WS-X
     MOVE 54 TO WS-Y
     PERFORM BLOCK-BOTH
     MOVE "acceptance US4-2 given the Player holds cardstack and aims at a west face when they use "
         & "the place control then a cardstack with axis x (state 7) appears west of it" TO TL-CASE
     MOVE "core 7 client 7" TO TL-EXPECTED
     PERFORM BOTH-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US4-6: a number key chooses the held hotbar slot; the world holds the same choice.
     MOVE CC-KEY-3 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     CALL "CV-STEP" USING CONVH
     CALL "CORE-PLAYER-SLOTS" USING WS-NAME WS-HELD WS-TEXT2
     MOVE "acceptance US4-6 given the Player has an inventory when they press number key 3 then "
         & "hotbar slot 2 is held, on the client and in the world" TO TL-CASE
     MOVE "client 2 core 2" TO TL-EXPECTED
     MOVE PL-HELD TO WS-E1
     MOVE WS-HELD TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "client " FUNCTION TRIM(WS-E1) " core " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US4-6: the inventory screen moves the loam of slot 1 to the empty slot 20.
     MOVE CC-KEY-E TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE SM-SCREEN TO WS-E4
     MOVE ACT-SLOT TO WS-ACTION
     MOVE 1 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 20 TO WS-ARG
     CALL "CV-CLICK" USING CONVH WS-ALICE WS-ACTION WS-ARG WS-FOUND
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM CLIENT-SLOTS
     CALL "CORE-PLAYER-SLOTS" USING WS-NAME WS-HELD WS-TEXT2
     MOVE "acceptance US4-6 given the inventory screen is open when the Player clicks the loam "
         & "slot 1 then the empty slot 20 then the loam is moved, on the client and in the world"
         TO TL-CASE
     MOVE "screen 6 client 0:63x2 2:64x4 3:64x5 4:62x6 5:64x7 6:64x8 7:64x9 8:1x10 9:1x11 20:64x3 "
         & "| core 0:63x2 2:64x4 3:64x5 4:62x6 5:64x7 6:64x8 7:64x9 8:1x10 9:1x11 20:64x3"
         TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E4) " client " FUNCTION TRIM(WS-TEXT) " | core "
         FUNCTION TRIM(WS-TEXT2) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY

*>   US4-3: survival break of the cardstack at (5, 54, 8) with greystone held (no tool): the hand
*>   break time 1.0 s; still there after 0.75 s, gone after the time; its item on the ground.
     MOVE CC-KEY-1 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5.5 TO WS-TX
     MOVE 54.5 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     MOVE 6 TO WS-ITEM
     CALL "COUNT-GROUND" USING CLIENT-STATE WS-ITEM WS-ITEMS0
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE 14 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 5 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM BLOCK-BOTH
     MOVE WS-CORE TO WS-E3
     MOVE WS-STATE TO WS-E4
     MOVE 8 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     PERFORM BLOCK-BOTH
     CALL "COUNT-GROUND" USING CLIENT-STATE WS-ITEM WS-ITEMS
     MOVE "acceptance US4-3 given the Player is in survival mode when they break a cardstack by "
         & "hand then it takes the 1.0 s break time, the block becomes empty and its item lies on "
         & "the ground where the block was" TO TL-CASE
     MOVE "after 0.75 s core 7 client 7; after 1.1 s core 0 client 0 new ground cardstacks 1"
         TO TL-EXPECTED
     MOVE WS-CORE TO WS-E1
     MOVE WS-STATE TO WS-E2
     COMPUTE WS-ITEMS = WS-ITEMS - WS-ITEMS0
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "after 0.75 s core " FUNCTION TRIM(WS-E3) " client " FUNCTION TRIM(WS-E4)
         "; after 1.1 s core " FUNCTION TRIM(WS-E1) " client " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-ITEMS TO WS-E1
     STRING " new ground cardstacks " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US4-5: a glowtube (key 7: slot 6) placed on the turf top (5, 53, 7) is lit; aimed at with the
*>   pry_bar (key 9: not a block item) the place control toggles it and the light follows.
     MOVE 50 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-KEY-7 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5.5 TO WS-TX
     MOVE 53.95 TO WS-TY
     MOVE 7.5 TO WS-TZ
     CALL "AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 5 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 7 TO WS-Z
     PERFORM BLOCK-BOTH
     MOVE WS-CORE TO WS-E3
     MOVE 55 TO WS-Y
     PERFORM LIGHT-CLIENT
     MOVE WS-LIGHT TO WS-E4
     MOVE CC-KEY-9 TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 5.5 TO WS-TX
     MOVE 54.5 TO WS-TY
     MOVE 7.5 TO WS-TZ
     CALL "AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     PERFORM USE-BUTTON
     MOVE 54 TO WS-Y
     PERFORM BLOCK-BOTH
     MOVE 55 TO WS-Y
     PERFORM LIGHT-CLIENT
     MOVE "acceptance US4-5 given the Player aims at a lit glowtube without holding a block item "
         & "when they use the place control then it switches to unlit and the light around it "
         & "goes out (to the 7 the marker glowtube at taxicab distance 8 gives)" TO TL-CASE
     MOVE "placed 13 light above 14; toggled core 14 client 14 light above 7" TO TL-EXPECTED
     MOVE WS-CORE TO WS-E1
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     STRING "placed " FUNCTION TRIM(WS-E3) " light above " FUNCTION TRIM(WS-E4)
         "; toggled core " FUNCTION TRIM(WS-E1) " client " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE WS-LIGHT TO WS-E1
     STRING " light above " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO TL-OBSERVED
         WITH POINTER WS-PTR
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     PERFORM USE-BUTTON
     MOVE 54 TO WS-Y
     PERFORM BLOCK-BOTH
     MOVE 55 TO WS-Y
     PERFORM LIGHT-CLIENT
     MOVE "acceptance US4-5 given an unlit glowtube when the Player uses the place control on it "
         & "again then it is lit and the light around it returns" TO TL-CASE
     MOVE "core 13 client 13 light above 14" TO TL-EXPECTED
     MOVE WS-CORE TO WS-E1
     MOVE WS-STATE TO WS-E2
     MOVE WS-LIGHT TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING "core " FUNCTION TRIM(WS-E1) " client " FUNCTION TRIM(WS-E2) " light above "
         FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   US4-4: in creative (the mode command; the host is an operator) a break is instant and no item
*>   appears: the greystone at (6, 54, 8).
     MOVE "/mode Alice creative" TO WS-SAY
     MOVE 20 TO WS-SAY-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-SAY WS-SAY-LENGTH
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE 6.5 TO WS-TX
     MOVE 54.5 TO WS-TY
     MOVE 8.5 TO WS-TZ
     CALL "AIM-AT" USING CLIENT-STATE WS-TX WS-TY WS-TZ
     MOVE 2 TO WS-ITEM
     CALL "COUNT-GROUND" USING CLIENT-STATE WS-ITEM WS-ITEMS0
     MOVE CC-BUTTON-LEFT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     CALL "CV-STEP" USING CONVH
     MOVE 6 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8 TO WS-Z
     PERFORM BLOCK-BOTH
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "COUNT-GROUND" USING CLIENT-STATE WS-ITEM WS-ITEMS
     MOVE "acceptance US4-4 given the Player is in creative mode when they break a block then it "
         & "breaks at once and no item appears" TO TL-CASE
     MOVE "mode 1 core 0 client 0 new ground greystones 0" TO TL-EXPECTED
     MOVE PL-MODE TO WS-E1
     MOVE WS-CORE TO WS-E2
     MOVE WS-STATE TO WS-E3
     COMPUTE WS-E4 = WS-ITEMS - WS-ITEMS0
     MOVE SPACES TO TL-OBSERVED
     STRING "mode " FUNCTION TRIM(WS-E1) " core " FUNCTION TRIM(WS-E2) " client "
         FUNCTION TRIM(WS-E3) " new ground greystones " FUNCTION TRIM(WS-E4)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*>   A use (right button down and up, two frames, then one more for the answer).
 USE-BUTTON.
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE 2 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N.

*>   The block at WS-X, WS-Y, WS-Z in the world (WS-CORE) and in the client's replica (WS-STATE).
 BLOCK-BOTH.
     CALL "CORE-BLOCK" USING WS-X WS-Y WS-Z WS-CORE
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-LIGHT.

 LIGHT-CLIENT.
     CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-ITEM WS-SKY WS-LIGHT.

 BOTH-OBSERVED.
     MOVE WS-CORE TO WS-E1
     MOVE WS-STATE TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING "core " FUNCTION TRIM(WS-E1) " client " FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO TL-OBSERVED.

*>   The client's non-empty slots as "<slot>:<count>x<item>" in WS-TEXT.
 CLIENT-SLOTS.
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         IF PL-SLOT-COUNT(WS-I) > 0
             COMPUTE WS-E1 = WS-I - 1
             MOVE PL-SLOT-COUNT(WS-I) TO WS-E2
             MOVE PL-SLOT-ITEM(WS-I) TO WS-E3
             IF WS-PTR > 1
                 STRING " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
             END-IF
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" FUNCTION TRIM(WS-E3)
                 DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM.
 END PROGRAM ACC-US4-CONTROLS-TO-WORLD.

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
