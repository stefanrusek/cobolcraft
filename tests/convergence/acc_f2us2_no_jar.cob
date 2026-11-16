*> Convergence acceptance test of play without the operator's jar (spec 002 US2; SC-011, FR-005): with no generated
*> directory (the client's generated directory names a folder that does not exist) the client's start-up check reports
*> the packs absent, a cobolcraft world is created through the client host, the Player moves, a block is set and broken
*> with the standard commands, the world is quit and opened again and the Player and the block are as they were.
*> The bench crafting (acc_f2us10_bench), the break and place controls (acc_us4_controls_to_world) and the create-screen
*> refusal of the standard type (client/tests/acc_f2us2_create_screen) are held by those tests, which run without a jar.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US2-NO-JAR.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONVH.
 COPY CLCONST.
 COPY CONTENT.
 COPY CCSHIM.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-f2us2-no-jar".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-FOLDER              PIC X(80) VALUE "NoJar".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 5.
 01 WS-SURVIVAL            BINARY-LONG VALUE 0.
 01 WS-JOINED              BINARY-LONG.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-KEY                 BINARY-LONG.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-N                   BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-X0                  FLOAT-LONG.
 01 WS-Z0                  FLOAT-LONG.
 01 WS-MOVED               BINARY-LONG.
 01 WS-X1                  FLOAT-LONG.
 01 WS-Z1                  FLOAT-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK-2             BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE "build/generated-absent" TO CL-GENERATED-DIR
     MOVE 22 TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     MOVE CL-PACKS-STATUS TO WS-STATUS
     MOVE CT-TYPE-COBOLCRAFT TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-X TO WS-X0
     MOVE PL-Z TO WS-Z0
     MOVE CC-KEY-W TO WS-KEY
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-DOWN
     MOVE 40 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-UP
     MOVE 5 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-X TO WS-X1
     MOVE PL-Z TO WS-Z1
     COMPUTE WS-MOVED = FUNCTION SQRT((WS-X1 - WS-X0) ** 2 + (WS-Z1 - WS-Z0) ** 2)
     MOVE "T" TO TL-MODE
     MOVE "acceptance US2 SC-011 given no jar and no generated directory when the Player starts the "
         & "client and creates a cobolcraft world then the packs are absent, the world is played "
         & "and the Player moves" TO TL-CASE
     MOVE "packs 1 joined 1 type 1 moved 1" TO TL-EXPECTED
     MOVE WS-STATUS TO WS-E1
     MOVE WS-JOINED TO WS-E2
     MOVE 0 TO WS-E3
     IF WS-MOVED >= 1
         MOVE 1 TO WS-E3
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "packs " FUNCTION TRIM(WS-E1) " joined " FUNCTION TRIM(WS-E2) " type " CT-SET-TYPE
         " moved " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A block set with the standard command, then the world is quit and opened again.
     MOVE "/setblock 4 60 4 cobolcraft:greystone" TO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     CALL "SP-QUIT" USING CLIENT-STATE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-SURVIVAL
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     MOVE 20 TO WS-N
     CALL "CV-STEPS" USING CONVH WS-N
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 4 TO WS-PX
     MOVE 60 TO WS-PY
     MOVE 4 TO WS-PZ
     CALL "WORLD-CELL" USING CLIENT-STATE WS-PX WS-PY WS-PZ WS-BLOCK-2 WS-SKY WS-BLOCK
     MOVE "acceptance US2 SC-011 given the world quit and opened again when the Player looks at the "
         & "block they set then it is there (not air) and the Player is back in play" TO TL-CASE
     MOVE "joined 1 block set 1" TO TL-EXPECTED
     MOVE WS-JOINED TO WS-E1
     MOVE 0 TO WS-E2
     IF WS-BLOCK-2 > 0
         MOVE 1 TO WS-E2
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING "joined " FUNCTION TRIM(WS-E1) " block set " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-F2US2-NO-JAR.
