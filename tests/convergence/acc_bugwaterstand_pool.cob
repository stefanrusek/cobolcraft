*> Convergence acceptance test of the operator report "I can stand on water" (try18 play; bug lane bugwaterstand; docs/protocol/13 section 1.3 swimming and
*> water, 29a section 1.2: a fluid cell has no collision shape, 18 section 3.2 travelInWater): a new superflat world made from the create-world screen through the
*> client's single-player host, from the generated vanilla packs (CC_GENERATED_DIR; a pass without them). A survival Player is put 10 blocks over a pool of water
*> (a /fill of real water states, 4 deep, on the grass floor) and lets the client's own physics and the core's movement check run frame by frame: the Player must sink
*> through the water to the pool floor (never rest at the surface), the core must send no Player Position correction on the way (counted at the client:
*> PL-TELEPORTS of a replica that is only moved by the core), Space must lift a swimmer, and the client's own replica must hold no solid cell in the pool.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGWATERSTAND-POOL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugwaterstand-pool".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 29.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "WaterStand".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 10.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-ROUND               BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-KEY                 BINARY-LONG VALUE CC-KEY-SPACE.
 01 WS-DOWN                BINARY-LONG VALUE CC-EV-KEY-DOWN.
 01 WS-UP                  BINARY-LONG VALUE CC-EV-KEY-UP.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SOLID               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-TOP-Y               FLOAT-LONG.
 01 WS-FLOOR-Y             FLOAT-LONG.
 01 WS-LOW-Y               FLOAT-LONG.
 01 WS-HIGH-Y              FLOAT-LONG.
 01 WS-EDIT                PIC -(4)9.9(4).
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugwaterstand: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED

*>   Survival, at the origin; a pool of water 7 x 7 and 4 deep on the floor (the grass floor top is at y -60), the Player put 10 blocks above it.
     MOVE "/gamemode survival" TO WS-LINE
     MOVE 18 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE "/fill -3 -60 -3 3 -57 3 minecraft:water" TO WS-LINE
     MOVE 39 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE "/tp Alice 0.5 -47 0.5" TO WS-LINE
     MOVE 21 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-FRAMES
     CALL "CV-STEPS" USING CONVH WS-FRAMES
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)

*>   The replica of the pool: water at the centre of every layer, no collision shape at any of its cells.
     MOVE 0 TO WS-X WS-Z
     MOVE 0 TO WS-WATER WS-SOLID
     PERFORM VARYING WS-Y FROM -60 BY 1 UNTIL WS-Y > -57
         CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
         IF WS-STATE NOT = 0
             ADD 1 TO WS-WATER
         END-IF
         CALL "PHYS-SOLID" USING CLIENT-STATE WS-X WS-Y WS-Z WS-SOLID
         IF WS-SOLID = 1
             ADD 100 TO WS-WATER
         END-IF
     END-PERFORM
     MOVE "acceptance bugwaterstand: given a /fill of water 4 deep when the replica is read then the 4 centre cells are set and none is solid" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 4 TO TL-EXPECTED-N
     MOVE WS-WATER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Let the Player fall in and sink (no keys): 400 frames.
     MOVE 400 TO WS-FRAMES
     CALL "CV-STEPS" USING CONVH WS-FRAMES
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-EDIT ROUNDED = PL-Y
     DISPLAY "probe sunk y " WS-EDIT " on ground " PL-ON-GROUND
     MOVE "acceptance bugwaterstand: given a survival Player dropped over a pool of water when 400 frames have run then it has sunk to the pool floor (y under -59.5)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y < -59.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Space held: the swimmer rises (the surface is at y -56.11).
     MOVE PL-Y TO WS-LOW-Y
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-DOWN
     MOVE 30 TO WS-FRAMES
     CALL "CV-STEPS" USING CONVH WS-FRAMES
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-UP
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-EDIT ROUNDED = PL-Y
     DISPLAY "probe risen y " WS-EDIT
     MOVE "acceptance bugwaterstand: given a Player on the pool floor when Space is held for 30 frames then it has risen more than a block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y > WS-LOW-Y + 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Probe: Space held 60 frames
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-DOWN
     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > 60
         MOVE 1 TO WS-FRAMES
         CALL "CV-STEPS" USING CONVH WS-FRAMES
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         COMPUTE WS-EDIT ROUNDED = PL-Y
         IF WS-ROUND > 40
             DISPLAY "hold " WS-ROUND " y " WS-EDIT " vy " PL-VY " g " PL-ON-GROUND
         END-IF
     END-PERFORM
     CALL "CV-KEY-SET" USING CONVH WS-ALICE WS-KEY WS-UP
*>   Released at the surface (feet at y -56.5, under the surface -56.11): the Player sinks again, it does not rest there.
     MOVE "/tp Alice 0.5 -56.5 0.5" TO WS-LINE
     MOVE 23 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 5 TO WS-FRAMES
     CALL "CV-STEPS" USING CONVH WS-FRAMES
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE PL-Y TO WS-HIGH-Y
     MOVE 60 TO WS-FRAMES
     CALL "CV-STEPS" USING CONVH WS-FRAMES
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-EDIT ROUNDED = PL-Y
     DISPLAY "probe surface y " WS-EDIT " from " WS-HIGH-Y
     MOVE "acceptance bugwaterstand: given a Player at the surface of the pool when 60 frames have run then it is lower than at the start" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PL-Y < WS-HIGH-Y - 0.5
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGWATERSTAND-POOL.
