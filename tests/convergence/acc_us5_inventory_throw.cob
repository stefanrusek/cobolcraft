*> Convergence test of the inventory-screen throws (tasks T1089; standin-content §9.1
*> "Inventory-screen throw"; client-surface §3 controls): the host of a single-player world (Alice,
*> survival) opens her inventory screen, presses Q over hotbar slot 0 (greystone) and drags the
*> loam of slot 1 out of the window; a second client on a further memory connection of the same
*> core (Bobby, at (4.5, 54, 30.5)) sees both ground items appear, and the world holds Alice's
*> inventory without them.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US5-INVENTORY-THROW.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-us5-inventory-throw".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-NAME                PIC X(16).
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Throws".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 6.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOBBY               BINARY-LONG.
 01 WS-JOINED-A            BINARY-LONG.
 01 WS-JOINED-B            BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE CC-BUTTON-LEFT.
 01 WS-PX                  FLOAT-SHORT.
 01 WS-PY                  FLOAT-SHORT.
 01 WS-OUT-X               FLOAT-SHORT VALUE 2.
 01 WS-OUT-Y               FLOAT-SHORT VALUE 2.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LINE                PIC X(64) VALUE "/relocate Bobby at 4.5 54 30.5".
 01 WS-SCREEN              BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-ITEM                BINARY-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     MOVE "Alice" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-FIVE WS-BOBBY
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED-A
     CALL "CV-ATTACH" USING CONVH WS-BOBBY
     CALL "CV-UNTIL-PLAY" USING CONVH WS-BOBBY WS-JOINED-B
     MOVE 30 TO WS-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LENGTH
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

*>   Alice opens the inventory screen (the cursor is free there, as the window loop makes it).
     MOVE CC-KEY-E TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SM-SCREEN TO WS-SCREEN
     MOVE 0 TO IN-CAPTURED

*>   Q over slot 0: the cursor moves there, then Q down and up.
     MOVE 0 TO WS-SLOT
     PERFORM SLOT-POS
     MOVE CC-EV-CURSOR TO WS-KIND
     MOVE 0 TO WS-I
     CALL "CV-QUEUE" USING CONVH WS-ALICE WS-KIND WS-I WS-PX WS-PY
     MOVE CC-KEY-Q TO WS-KEY
     MOVE CC-EV-KEY-DOWN TO WS-KIND
     CALL "CV-QUEUE" USING CONVH WS-ALICE WS-KIND WS-KEY WS-PX WS-PY
     MOVE CC-EV-KEY-UP TO WS-KIND
     CALL "CV-QUEUE" USING CONVH WS-ALICE WS-KIND WS-KEY WS-PX WS-PY
     CALL "CV-STEP" USING CONVH

*>   A left drag from slot 1 released outside the window.
     MOVE 1 TO WS-SLOT
     PERFORM SLOT-POS
     MOVE CC-EV-BUTTON-DOWN TO WS-KIND
     CALL "CV-QUEUE" USING CONVH WS-ALICE WS-KIND WS-BUTTON WS-PX WS-PY
     CALL "CV-STEP" USING CONVH
     MOVE CC-EV-CURSOR TO WS-KIND
     MOVE 0 TO WS-I
     CALL "CV-QUEUE" USING CONVH WS-ALICE WS-KIND WS-I WS-OUT-X WS-OUT-Y
     MOVE CC-EV-BUTTON-UP TO WS-KIND
     CALL "CV-QUEUE" USING CONVH WS-ALICE WS-KIND WS-BUTTON WS-OUT-X WS-OUT-Y
     CALL "CV-STEP" USING CONVH
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N

     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-BOBBY)
     MOVE 2 TO WS-ITEM
     PERFORM GROUND-SUM
     MOVE WS-SUM TO WS-E1
     MOVE 3 TO WS-ITEM
     PERFORM GROUND-SUM
     MOVE WS-SUM TO WS-E2
     CALL "CORE-SLOTS" USING WS-TEXT
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-CARRIED-COUNT TO WS-E3
     MOVE WS-SCREEN TO WS-E4
     MOVE "convergence inventory throw given the inventory screen when Alice presses Q over "
         & "greystone and drags the loam out of the window then Bobby sees 1 greystone and 64 "
         & "loam on the ground and the world's inventory lacks them" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "screen 6 bobby greystone 1 loam 64 | alice cursor 0 | core 0:63x2 1:0x0" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     STRING "screen " FUNCTION TRIM(WS-E4) " bobby greystone " FUNCTION TRIM(WS-E1) " loam "
         FUNCTION TRIM(WS-E2) " | alice cursor " FUNCTION TRIM(WS-E3) " | core "
         FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Window position of the centre of Alice's slot widget WS-SLOT (WS-PX, WS-PY).
 SLOT-POS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-KIND(WS-I) = WK-SLOT AND SM-W-ARG(WS-I) = WS-SLOT
             COMPUTE WS-PX = (SM-W-X(WS-I) + SM-W-W(WS-I) / 2) * CL-GUI-SCALE
             COMPUTE WS-PY = (SM-W-Y(WS-I) + SM-W-H(WS-I) / 2) * CL-GUI-SCALE
         END-IF
     END-PERFORM.

*> The total count of item WS-ITEM in the ground items of the current client's replica.
 GROUND-SUM.
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = 1 AND EN-STACK-ITEM(WS-I) = WS-ITEM
             ADD EN-STACK-COUNT(WS-I) TO WS-SUM
         END-IF
     END-PERFORM.
 END PROGRAM ACC-US5-INVENTORY-THROW.

*> CORE-SLOTS USING text out (PIC X(1024)): slots 0 and 1 of the world's online player Alice as
*> "0:<count>x<item> 1:<count>x<item>" (test infrastructure).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. CORE-SLOTS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-E4                  PIC -(9)9.
 LINKAGE SECTION.
 01 L-TEXT                 PIC X(1024).
 PROCEDURE DIVISION USING L-TEXT.
     MOVE 0 TO WS-ROW
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64 OR WS-ROW > 0
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = "Alice"
             MOVE WS-R TO WS-ROW
         END-IF
     END-PERFORM
     MOVE PL-SLOT-COUNT(WS-ROW, 1) TO WS-E1
     MOVE PL-SLOT-ITEM(WS-ROW, 1) TO WS-E2
     MOVE PL-SLOT-COUNT(WS-ROW, 2) TO WS-E3
     MOVE PL-SLOT-ITEM(WS-ROW, 2) TO WS-E4
     MOVE SPACES TO L-TEXT
     STRING "0:" FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) " 1:" FUNCTION TRIM(WS-E3) "x"
         FUNCTION TRIM(WS-E4) DELIMITED BY SIZE INTO L-TEXT
     GOBACK.
 END PROGRAM CORE-SLOTS.
