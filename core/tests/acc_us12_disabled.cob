*> Acceptance test, US12-4 core half (spec US12 scenario 4; tasks T590; standin-content §5.1, §15.1,
*> §15.5; FR-009): with the extra-dimensions setting off, using a goto_pad does nothing (the player
*> stays where they are; only the Block Changed Ack is sent and no block is placed in
*> cobolcraft:subroutine), a player whose stored dimension is cobolcraft:subroutine joins at the
*> world spawn point in cobolcraft:main, and the Login lists only cobolcraft:main. The stored place
*> of a player is set directly in the known-player table (persistence across runs is US13).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-DISABLED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY PROTO.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQUENCE            BINARY-LONG VALUE 1.
 01 WS-I                   BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-N                   BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-E3                  PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT2               PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES CS-EXTRA-DIMENSIONS

     MOVE "acceptance US12-4 given extra-dimensions off when Alice uses the goto_pad at (6, 54, 12) "
         & "then she stays: only the Block Changed Ack, still in cobolcraft:main at the spawn point, "
         & "nothing placed in the Subroutine column" TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE DIM-MAIN TO WS-DIM
     MOVE 6 TO WS-X MOVE 54 TO WS-Y MOVE 12 TO WS-Z
     MOVE TRAVEL-PAD-STATE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQUENCE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE PL-DIM(WS-ROW) TO WS-E1
     COMPUTE WS-E2 = PL-X(WS-ROW) * 10
     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE 35 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-E3
     MOVE WS-TEXT TO WS-TEXT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TEXT2) " dim " FUNCTION TRIM(WS-E1) " x10 " FUNCTION TRIM(WS-E2)
         " subroutine block " FUNCTION TRIM(WS-E3) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "4 dim 1 x10 45 subroutine block 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-4 given extra-dimensions off and Alice stored in cobolcraft:subroutine at "
         & "(6.5, 36, 12.5) when she joins then she is at the world spawn point in cobolcraft:main"
         TO TL-CASE
     CALL "CORE-CONN-CLOSED" USING WS-ALICE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > KN-COUNT
         MOVE 1 TO KN-PLACED(WS-I)
         MOVE DIM-SUBROUTINE TO KN-DIM(WS-I)
         MOVE 6.5 TO KN-X(WS-I)
         MOVE 36 TO KN-Y(WS-I)
         MOVE 12.5 TO KN-Z(WS-I)
     END-PERFORM
     CALL "TEST-JOIN-UNDRAINED" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     CALL "TEST-DRAIN-HEALTH" USING WS-ALICE WS-TEXT
     MOVE PL-DIM(CN-PLAYER(WS-ALICE)) TO WS-E1
     MOVE WS-TEXT TO WS-TEXT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TEXT2) " dim " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "position 4.5 54.0 8.5 dim 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-4 given extra-dimensions off then the Login lists only cobolcraft:main"
         TO TL-CASE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PLAY-LOGIN-BUILD" USING WS-ROW PB-BUFFER
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-N
     CALL "PB-GET-INT" USING PB-BUFFER WS-N
     CALL "PB-GET-BOOL" USING PB-BUFFER WS-N
     CALL "PB-GET-VARINT" USING PB-BUFFER WS-COUNT
     MOVE WS-COUNT TO WS-E1
     MOVE SPACES TO WS-TEXT
     STRING "names " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     PERFORM WS-COUNT TIMES
         CALL "PB-GET-IDENTIFIER" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
         MOVE WS-TEXT TO WS-TEXT2
         MOVE SPACES TO WS-TEXT
         STRING FUNCTION TRIM(WS-TEXT2) " " WS-KEY(1:WS-KEY-LENGTH) DELIMITED BY SIZE
             INTO WS-TEXT
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     MOVE "names 1 cobolcraft:main" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-DISABLED.

 COPY CORETEST.
