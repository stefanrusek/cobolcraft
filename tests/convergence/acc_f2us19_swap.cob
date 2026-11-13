*> Convergence acceptance test of US19-1 to US19-3 (spec 002 FR-020; 13 §4; core Container Set Slot answers): a survival
*> Player in a single-player world (the client's in-process core) swaps with the off hand. F with no screen open
*> sends the swap action and the client's replica follows the core's Set Slot answers: hotbar slot 0 (64 greystone,
*> held) and the off hand exchange. In the inventory screen with the mouse over hotbar slot 1 (64 loam) F sends the
*> Container Click swap: that slot and the off hand exchange (the off hand held the greystone). Back in the world F
*> exchanges the held slot with the off hand again. After each step the client and the core hold the same stacks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US19-SWAP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us19-swap".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 22.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "Swap".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 4.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-BUTTON              BINARY-LONG VALUE 0.
 01 WS-CX                  FLOAT-SHORT.
 01 WS-CY                  FLOAT-SHORT.
 01 WS-HIT                 BINARY-LONG.
 01 WS-CLIENT              PIC X(120).
 01 WS-CORE                PIC X(120).
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
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
     MOVE "T" TO TL-MODE

     PERFORM SNAPSHOT
     MOVE "acceptance US19-1 setup given a first-time Player when they join then slot 0 holds 64 "
         & "greystone, slot 1 64 loam and the off hand is empty, in the client and in the world" TO TL-CASE
     MOVE "client 0:64x2 1:64x3 off 0x0 | core 0:64x2 1:64x3 off 0x0" TO TL-EXPECTED
     PERFORM CHECK

*>   US19-1: F with no screen open.
     MOVE CC-KEY-F TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 4 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM SNAPSHOT
     MOVE "acceptance US19-1 given the Player holds 64 greystone and the off hand is empty when they "
         & "press F then the stack is in the off hand and the held slot is empty, in the client (from "
         & "the Set Slot answers) and in the world" TO TL-CASE
     MOVE "client 0:0x0 1:64x3 off 64x2 | core 0:0x0 1:64x3 off 64x2" TO TL-EXPECTED
     PERFORM CHECK

*>   US19-2: the inventory screen, the mouse over hotbar slot 1 (loam), F.
     MOVE CC-KEY-E TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     CALL "CV-STEP" USING CONVH
     MOVE 0 TO WS-HIT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SM-WIDGET-COUNT
         IF SM-W-ACTION(WS-I) = ACT-SLOT AND SM-W-ARG(WS-I) = 1
             MOVE WS-I TO WS-HIT
         END-IF
     END-PERFORM
     COMPUTE WS-CX = (SM-W-X(WS-HIT) + 5) * CL-GUI-SCALE
     COMPUTE WS-CY = (SM-W-Y(WS-HIT) + 5) * CL-GUI-SCALE
     MOVE CC-EV-CURSOR TO WS-KIND
     CALL "CV-QUEUE" USING CONVH WS-ALICE WS-KIND WS-BUTTON WS-CX WS-CY
     CALL "CV-STEP" USING CONVH
     MOVE CC-KEY-F TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 4 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM SNAPSHOT
     MOVE "acceptance US19-2 given the inventory screen with the mouse over hotbar slot 1 and 64 "
         & "greystone in the off hand when the Player presses F then slot 1 holds the greystone and "
         & "the off hand the loam, in the client and in the world" TO TL-CASE
     MOVE "client 0:0x0 1:64x2 off 64x3 | core 0:0x0 1:64x2 off 64x3" TO TL-EXPECTED
     PERFORM CHECK

*>   Back in the world, F swaps the held slot (empty) with the off hand (loam).
     MOVE CC-KEY-ESCAPE TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 3 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     MOVE CC-KEY-F TO WS-KEY
     CALL "CV-KEY" USING CONVH WS-ALICE WS-KEY
     MOVE 4 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     PERFORM SNAPSHOT
     MOVE "acceptance US19-1 given an empty held slot and loam in the off hand when the Player presses "
         & "F in the world then the loam is held and the off hand is empty, in the client and in the "
         & "world" TO TL-CASE
     MOVE "client 0:64x3 1:64x2 off 0x0 | core 0:64x3 1:64x2 off 0x0" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE SPACES TO TL-OBSERVED
     STRING "client " FUNCTION TRIM(WS-CLIENT) " | core " FUNCTION TRIM(WS-CORE) DELIMITED BY SIZE
         INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*>   WS-CLIENT and WS-CORE: "0:<n>x<item> 1:<n>x<item> off <n>x<item>" of the client's replica and the world's record.
 SNAPSHOT.
     MOVE SPACES TO WS-CLIENT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
         COMPUTE WS-E1 = WS-I - 1
         MOVE PL-SLOT-COUNT(WS-I) TO WS-E2
         STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" DELIMITED BY SIZE
             INTO WS-CLIENT WITH POINTER WS-PTR
         MOVE PL-SLOT-ITEM(WS-I) TO WS-E2
         IF PL-SLOT-COUNT(WS-I) = 0
             MOVE 0 TO WS-E2
         END-IF
         STRING FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO WS-CLIENT WITH POINTER WS-PTR
     END-PERFORM
     MOVE PL-OFFHAND-COUNT TO WS-E1
     MOVE PL-OFFHAND-ITEM TO WS-E2
     IF PL-OFFHAND-COUNT = 0
         MOVE 0 TO WS-E2
     END-IF
     STRING "off " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
         INTO WS-CLIENT WITH POINTER WS-PTR
     CALL "F2CF-CORE-SNAP" USING WS-NAME WS-CORE.
 END PROGRAM ACC-F2US19-SWAP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. F2CF-CORE-SNAP.
*> USING name (PIC X(16)), text out (PIC X(120)): the world's record of that online player, as the test's client
*> text: hotbar slots 0 and 1 and the off hand (menu slot 45).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CMENU.
 01 WS-R                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-TEXT                 PIC X(120).
 PROCEDURE DIVISION USING L-NAME L-TEXT.
     MOVE 0 TO WS-P
     MOVE "none" TO L-TEXT
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64 OR WS-P > 0
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = L-NAME
             MOVE WS-R TO WS-P
         END-IF
     END-PERFORM
     IF WS-P > 0
         MOVE SPACES TO L-TEXT
         MOVE 1 TO WS-PTR
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2
             COMPUTE WS-E1 = WS-I - 1
             MOVE PL-SLOT-COUNT(WS-P, WS-I) TO WS-E2
             STRING FUNCTION TRIM(WS-E1) ":" FUNCTION TRIM(WS-E2) "x" DELIMITED BY SIZE
                 INTO L-TEXT WITH POINTER WS-PTR
             MOVE PL-SLOT-ITEM(WS-P, WS-I) TO WS-E2
             IF PL-SLOT-COUNT(WS-P, WS-I) = 0
                 MOVE 0 TO WS-E2
             END-IF
             STRING FUNCTION TRIM(WS-E2) " " DELIMITED BY SIZE INTO L-TEXT WITH POINTER WS-PTR
         END-PERFORM
         MOVE MN-EQUIP-COUNT(WS-P, 5) TO WS-E1
         MOVE MN-EQUIP-ITEM(WS-P, 5) TO WS-E2
         IF MN-EQUIP-COUNT(WS-P, 5) = 0
             MOVE 0 TO WS-E2
         END-IF
         STRING "off " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2) DELIMITED BY SIZE
             INTO L-TEXT WITH POINTER WS-PTR
     END-IF
     GOBACK.
 END PROGRAM F2CF-CORE-SNAP.
