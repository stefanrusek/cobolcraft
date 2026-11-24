*> Acceptance test, US5-2 core half (spec US5 scenario 2; tasks T468; standin-content §9.2 step 4,
*> §9.3; data-model §4 add rule, §5): a ground item within the pickup range of a survival or a
*> creative player leaves the ground (Take Item Entity, Remove Entities to its viewers) and is added
*> to that player's inventory (Container Set Slot). View distance 2. Alice (entity 1, survival,
*> starting items, pry_bar held) stays at the spawn point and breaks greystone at (22, 101, 20) on a
*> greystone floor at y = 100 (x 18 to 26, z 18 to 22); the yield (a random popResource position near (22.5, 101, 20.5),
*> 41 section 2.1, pickup delay 10) comes to rest on it. Bob (entity 2) is made
*> creative after joining (mode changes by command are US14). Both players start with the
*> survival starting items, so slot 0 (64 greystone) is full and the item goes to slot 10, the
*> first empty slot.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US5-PICKUP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-BOB                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 22.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG VALUE 20.
 01 WS-STATE               BINARY-LONG VALUE 2.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-ACTION              BINARY-LONG.
 01 WS-SLOT                BINARY-LONG VALUE 8.
 01 WS-TICKS               BINARY-LONG.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG VALUE 101.0.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-E1                  PIC -(9)9.
 01 WS-E2                  PIC -(9)9.
 01 WS-R1                  PIC -(6)9.99.
 01 WS-R2                  PIC -(6)9.99.
 01 WS-R3                  PIC -(6)9.99.
 01 WS-ADD                 PIC X(80).
 01 WS-BEFORE              PIC X(1024).
 01 WS-FLOOR-X             BINARY-LONG.
 01 WS-FLOOR-Z             BINARY-LONG.
 01 WS-ENTITY              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE "Bobby" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-BOB
     MOVE 1 TO PL-MODE(CN-PLAYER(WS-BOB))
     MOVE 100 TO WS-Y
     PERFORM VARYING WS-FLOOR-X FROM 18 BY 1 UNTIL WS-FLOOR-X > 26
         PERFORM VARYING WS-FLOOR-Z FROM 18 BY 1 UNTIL WS-FLOOR-Z > 22
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-FLOOR-X WS-Y WS-FLOOR-Z WS-STATE
         END-PERFORM
     END-PERFORM
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT

     MOVE "acceptance US5-2 given a ground item when a creative player is within pickup range "
         & "then once its pickup delay (10 ticks) is over it is taken (Take Item Entity, "
         & "inventory update, Remove Entities) and added, first on the eleventh tick" TO TL-CASE
     MOVE 21.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     PERFORM BREAK-BLOCK
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     MOVE 10 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     CALL "TEST-DROP-MOVES" USING WS-TEXT
     MOVE WS-TEXT TO WS-BEFORE
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-BOB WS-TEXT
     CALL "TEST-DROP-MOVES" USING WS-TEXT
     MOVE SPACES TO TL-OBSERVED
     STRING "before [" FUNCTION TRIM(WS-BEFORE) "] after [" FUNCTION TRIM(WS-TEXT) "]"
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT
     MOVE CN-PLAYER(WS-BOB) TO WS-ROW
     PERFORM ADD-SLOT
     MOVE "before [] after [127(3,2,1) 20(10=2x1) 78(3)] slot 10 2x1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-2 given a ground item picked up by a creative player then the other "
         & "viewers, who saw it appear and fall, are sent Take Item Entity and Remove Entities too" TO TL-CASE
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-DROP-MOVES" USING WS-TEXT
     MOVE SPACES TO TL-EXPECTED
     STRING "5 4 5x8 49 " FUNCTION TRIM(WS-ADD) " 101(3=2x1) 103(3) 8 4 127(3,2,1) 78(3)"
         DELIMITED BY SIZE INTO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US5-2 given a ground item resting out of every player's range when a "
         & "survival player walks within pickup range then it leaves the ground and is added to "
         & "that player's inventory" TO TL-CASE
     MOVE 40.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-BOB WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     PERFORM BREAK-BLOCK
     MOVE 20 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE 21.5 TO WS-FX
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE 1 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     CALL "TEST-DROP-MOVES" USING WS-TEXT
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     PERFORM ADD-SLOT
     MOVE "127(4,1,1) 20(10=2x1) 78(4) slot 10 2x1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

*> Puts greystone at (22, 101, 20), breaks it as Alice with the pry_bar (7 ticks).
 BREAK-BLOCK.
     MOVE 101 TO WS-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-ACTION
     PERFORM ACT
     MOVE 7 TO WS-TICKS
     CALL "TEST-TICKS" USING WS-TICKS
     MOVE 3 TO WS-ACTION
     PERFORM ACT
     COMPUTE WS-ENTITY = CW-NEXT-ENTITY-ID - 1
     CALL "TEST-FIND-ENTITY" USING WS-ENTITY WS-ROW
     COMPUTE WS-R1 ROUNDED = EN-X(WS-ROW)
     COMPUTE WS-R2 ROUNDED = EN-Y(WS-ROW)
     COMPUTE WS-R3 ROUNDED = EN-Z(WS-ROW)
     MOVE WS-ENTITY TO WS-E1
     MOVE SPACES TO WS-ADD
     STRING "1(" FUNCTION TRIM(WS-E1) ",1@" FUNCTION TRIM(WS-R1) "," FUNCTION TRIM(WS-R2) ","
         FUNCTION TRIM(WS-R3) ")" DELIMITED BY SIZE INTO WS-ADD.

 ACT.
     ADD 1 TO WS-SEQ
     CALL "TEST-ACTION" USING WS-ALICE WS-ACTION WS-X WS-Y WS-Z WS-FACE WS-SEQ.

*> Appends " slot 10 <item>x<count>" of player row WS-ROW to WS-TEXT.
 ADD-SLOT.
     MOVE PL-SLOT-ITEM(WS-ROW, 11) TO WS-E1
     MOVE PL-SLOT-COUNT(WS-ROW, 11) TO WS-E2
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " slot 10 " FUNCTION TRIM(WS-E1) "x" FUNCTION TRIM(WS-E2)
         DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE TL-OBSERVED TO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US5-PICKUP.

 COPY CORETEST.
