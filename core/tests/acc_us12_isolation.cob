*> Acceptance test, US12-2 core half and the US12 edge case "mobs and ground items near a traveller"
*> (spec US12 scenario 2 and edge cases; tasks T584; standin-content §15.5, §12.5, §9; 09 §3.2 entity
*> rows): players in different dimensions are not sent each other's world changes, entities or
*> movement (TEST-DRAIN-ENTITIES lists packets other than entity packets by id); once a player has travelled into the other's dimension they see each other. Mobs and
*> ground items next to a traveller stay in the dimension they were in, and the traveller's client is
*> not sent them afterwards. Travel uses the goto_pad at (6, 54, 12) of cobolcraft:main (turf at 53),
*> arriving in cobolcraft:subroutine at feet (6.5, 36, 12.5) (slag at 34, arrival pad at 35). Alice
*> joins first (entity id 1), Bob second (entity id 2); both are creative.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US12-ISOLATION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY ETIDS.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-ACTION              BINARY-LONG VALUE 0.
 01 WS-SEQUENCE            BINARY-LONG VALUE 0.
 01 WS-FIVE                BINARY-LONG VALUE 5.
 01 WS-TYPE                BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-ITEM-ROW            BINARY-LONG.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-COUNT               BINARY-LONG VALUE 1.
 01 WS-DELAY               BINARY-LONG VALUE 1000.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-TEXT                PIC X(4096).
 01 WS-TEXT2               PIC X(4096).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 1 TO CS-EXTRA-DIMENSIONS

     MOVE "acceptance US12-2 given Alice and Bob in cobolcraft:main seeing each other when Alice "
         & "travels to cobolcraft:subroutine then Bob is sent Remove Entities of Alice and neither "
         & "client has the other" TO TL-CASE
     PERFORM OPEN-AND-JOIN-BOTH
     MOVE WS-ALICE TO WS-A
     PERFORM USE-MAIN-PAD
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     PERFORM APPEND-SEEN
     MOVE "78(1) seen 0 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-2 given Alice in the Subroutine and Bob in main when Alice breaks the "
         & "slag at (7, 34, 12) then Bob is sent nothing" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE 7 TO WS-X MOVE 34 TO WS-Y MOVE 12 TO WS-Z
     ADD 1 TO WS-SEQUENCE
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQUENCE
     CALL "TEST-DRAIN-BLOCKS" USING WS-BOB WS-TEXT
     PERFORM APPEND-BLOCK
     MOVE "block 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-2 given Bob in main and Alice in the Subroutine when Bob breaks the turf "
         & "at (7, 53, 12) then Alice is sent nothing" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE DIM-MAIN TO WS-DIM
     MOVE 53 TO WS-Y
     ADD 1 TO WS-SEQUENCE
     CALL "TEST-ACTION" USING WS-BOB WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQUENCE
     CALL "TEST-DRAIN-BLOCKS" USING WS-ALICE WS-TEXT
     PERFORM APPEND-BLOCK
     MOVE "block 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-2 given Bob in main and Alice in the Subroutine when Bob moves then "
         & "Alice is sent nothing" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-TEXT
     MOVE 5.5 TO WS-FX
     MOVE 54 TO WS-FY
     MOVE 8.5 TO WS-FZ
     MOVE 31 TO WS-STATE
     MOVE 1 TO WS-COUNT
     CALL "TEST-MOVE" USING WS-BOB WS-STATE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-COUNT
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12-2 given Alice in the Subroutine when Bob travels there too then each is "
         & "sent the other (Add Entity), and Bob's client has the change Alice made there" TO TL-CASE
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-TEXT
     MOVE WS-BOB TO WS-A
     PERFORM USE-MAIN-PAD
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE WS-TEXT TO WS-TEXT2
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     STRING "Alice " FUNCTION TRIM(WS-TEXT2) " Bob " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
         INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     PERFORM APPEND-SEEN
     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE 7 TO WS-X
     MOVE 34 TO WS-Y
     PERFORM APPEND-BLOCK
     MOVE "Alice 1(2,0@6.50,36.00,12.50) Bob 4 84 65 107 18 99 39x4 96 12 46x25 11 73 "
         & "1(1,0@6.50,36.00,12.50) seen 1 1 block 0" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "US12 edge given a sodgrazer and a ground item next to Alice in main when she travels "
         & "then both stay in main where they were and her client is not sent them afterwards"
         TO TL-CASE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE DIM-MAIN TO WS-DIM
     MOVE 6 TO WS-X MOVE 54 TO WS-Y MOVE 12 TO WS-Z
     MOVE TRAVEL-PAD-STATE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE ET-SODGRAZER TO WS-TYPE
     MOVE 3.5 TO WS-FX
     MOVE 54 TO WS-FY
     MOVE 9.5 TO WS-FZ
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-MOB
     MOVE 5.5 TO WS-FX
     MOVE 54 TO WS-FY
     MOVE 10.5 TO WS-FZ
     MOVE 1 TO WS-COUNT
     CALL "GI-SPAWN" USING WS-DIM WS-FX WS-FY WS-FZ WS-V0 WS-V1 WS-V2 WS-ITEM WS-COUNT WS-DELAY
         WS-ITEM-ROW
     MOVE WS-ALICE TO WS-A
     PERFORM USE-MAIN-PAD
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "TEST-TICKS" USING WS-FIVE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE EN-DIM(WS-MOB) TO WS-E1
     MOVE EN-DIM(WS-ITEM-ROW) TO WS-E2
     MOVE WS-TEXT TO WS-TEXT2
     MOVE SPACES TO WS-TEXT
     STRING "sent [" FUNCTION TRIM(WS-TEXT2) "] mob dim " FUNCTION TRIM(WS-E1) " item dim "
         FUNCTION TRIM(WS-E2) " seen " VW-SEEN(CN-PLAYER(WS-ALICE))(WS-MOB:1) "|"
         VW-SEEN(CN-PLAYER(WS-ALICE))(WS-ITEM-ROW:1) "|" DELIMITED BY SIZE INTO WS-TEXT
     MOVE PL-DIM(CN-PLAYER(WS-ALICE)) TO WS-E1
     MOVE WS-TEXT TO WS-TEXT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TEXT2) " alice dim " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE
         INTO WS-TEXT
     MOVE "sent [] mob dim 1 item dim 1 seen  | | alice dim 2" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Opens the world (night, so no sodgrazer spawns); Alice then Bob join at the spawn point; the
*> goto_pad at (6, 54, 12) of main is placed; both are drained.
 OPEN-AND-JOIN-BOTH.
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 16001 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     MOVE 5 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bob" TO WS-NAME
     MOVE 3 TO WS-NAME-LENGTH
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE DIM-MAIN TO WS-DIM
     MOVE 6 TO WS-X MOVE 54 TO WS-Y MOVE 12 TO WS-Z
     MOVE TRAVEL-PAD-STATE TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     CALL "TEST-DRAIN-IDS" USING WS-BOB WS-TEXT.

*> The player of connection WS-A uses the goto_pad at (6, 54, 12) of main.
 USE-MAIN-PAD.
     MOVE 6 TO WS-X MOVE 54 TO WS-Y MOVE 12 TO WS-Z
     ADD 1 TO WS-SEQUENCE
     CALL "TEST-USE-ON" USING WS-A WS-X WS-Y WS-Z WS-FACE WS-SEQUENCE.

*> " seen <a> <b>": whether Alice's client has Bob's entity, and Bob's client Alice's.
 APPEND-SEEN.
     MOVE CN-PLAYER(WS-ALICE) TO WS-A
     MOVE CN-PLAYER(WS-BOB) TO WS-B
     MOVE 0 TO WS-E1 WS-E2
     IF VW-SEEN(WS-A)(PL-ENTITY-ROW(WS-B):1) = "1"
         MOVE 1 TO WS-E1
     END-IF
     IF VW-SEEN(WS-B)(PL-ENTITY-ROW(WS-A):1) = "1"
         MOVE 1 TO WS-E2
     END-IF
     MOVE WS-TEXT TO WS-TEXT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TEXT2) " seen " FUNCTION TRIM(WS-E1) " " FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO WS-TEXT
     MOVE FUNCTION TRIM(WS-TEXT) TO WS-TEXT2
     MOVE WS-TEXT2 TO WS-TEXT.

*> " block <state>": the block at (x, y, z) of WS-DIM.
 APPEND-BLOCK.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-E1
     MOVE WS-TEXT TO WS-TEXT2
     MOVE SPACES TO WS-TEXT
     STRING FUNCTION TRIM(WS-TEXT2) " block " FUNCTION TRIM(WS-E1) DELIMITED BY SIZE INTO WS-TEXT
     MOVE FUNCTION TRIM(WS-TEXT) TO WS-TEXT2
     MOVE WS-TEXT2 TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US12-ISOLATION.

 COPY CORETEST.
