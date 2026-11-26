*> Convergence acceptance test of the items that the server uses with Use Item (lane bugusein T63304; docs/protocol/17 sections 3.9 and 3.10, 25 part 7 and section 6.3, 29 section 9, 09 section 3.3), in a new
*> standard world made from the create-world screen through the client's single-player host, from the generated vanilla packs (CC_GENERATED_DIR; a pass without them). The player plays in survival and
*> works the real mouse buttons: a boat held and the right button pressed on the ground places an oak_boat and uses the item up; a bow held with an arrow in the pack, the right button held for ten ticks
*> and let go shoots one arrow (Use Item starts the draw, Player Action 6 shoots) and uses one arrow; an ender pearl pressed on the ground is thrown; the same pearl pressed on a crafting table opens the
*> window and is not thrown (Use Item On took the click).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGUSEIN-USE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 COPY CCSHIM.
 COPY CONTENT.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugusein-use".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 23.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "UseItems".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 8.
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
 01 WS-CHAT                PIC X(4096).
 01 WS-SUGGESTED           PIC X(1024).
 01 WS-HAS                 BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-PAUSE               PIC 9V99 VALUE 0.25.
 01 WS-BUTTON              BINARY-LONG.
 01 WS-DOWN                BINARY-LONG.
 01 WS-KEY-TYPE            PIC X(24).
 01 WS-KEY-ITEM-NAME       PIC X(24).
 01 WS-KEY-ITEM            BINARY-LONG.
 01 WS-ROWS                BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-OBSERVE             BINARY-LONG.
 01 WS-BEFORE              BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-PZ1                 BINARY-LONG.
 01 WS-PZ2                 BINARY-LONG.
 01 WS-EDIT-X              PIC -(9)9.
 01 WS-EDIT-Y              PIC -(9)9.
 01 WS-EDIT-Z              PIC -(9)9.
 01 WS-EDIT-X2             PIC -(9)9.
 01 WS-EDIT-Y2             PIC -(9)9.
 01 WS-EDIT-Z2             PIC -(9)9.
  01 WS-E1                  BINARY-LONG.
 01 WS-LO-X                BINARY-LONG.
 01 WS-LO-Z                BINARY-LONG.
 01 WS-HI-X                BINARY-LONG.
 01 WS-HI-Z                BINARY-LONG.
 01 WS-FLOOR-Y             BINARY-LONG.
 01 WS-TOP-Y               BINARY-LONG.
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
         MOVE "acceptance bugusein: no generated packs here, skipped" TO TL-CASE
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
     CALL "PACKS-STATUS-CHECK" USING CLIENT-STATE
     CALL "PACKS-RELOAD" USING CLIENT-STATE
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CT-TYPE-STANDARD TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
*>   the loading screen is left when the chunks round the player have come from the generation workers (real time)
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > 800 OR SM-SCREEN = SCR-WORLD
         MOVE 10 TO WS-FRAMES
         CALL "CV-STEPS" USING CONVH WS-FRAMES
         CALL "C$SLEEP" USING WS-PAUSE
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     END-PERFORM

*>   survival, an empty pack
     MOVE "/gamemode survival" TO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE "N" TO TL-MODE

*>   the ground under and ahead of the player is made level: a stone floor with clear air above (the terrain of a random seed may slope, and a boat whose box would overlap
*>   the ground is refused, as in Minecraft)
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-LO-X = FUNCTION INTEGER(PL-X) - 3
     COMPUTE WS-HI-X = FUNCTION INTEGER(PL-X) + 3
     COMPUTE WS-LO-Z = FUNCTION INTEGER(PL-Z) - 3
     COMPUTE WS-HI-Z = FUNCTION INTEGER(PL-Z) + 4
     COMPUTE WS-FLOOR-Y = FUNCTION INTEGER(PL-Y) - 1
     COMPUTE WS-TOP-Y = WS-FLOOR-Y + 4
     PERFORM FILL-AIR
     PERFORM FILL-STONE
     MOVE "N" TO TL-MODE

*>   a boat pressed on the ground (looking 50 degrees down)
     MOVE "/clear Alice" TO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE "/give Alice oak_boat 1" TO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE 0 TO PL-YAW
     MOVE 50 TO PL-PITCH
     PERFORM CLICK
     MOVE "acceptance bugusein: a boat pressed on the ground makes one oak_boat entity" TO TL-CASE
     MOVE "oak_boat" TO WS-KEY-TYPE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM COUNT-CORE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugusein: and the boat is used up" TO TL-CASE
     MOVE "oak_boat" TO WS-KEY-ITEM-NAME
     MOVE 0 TO TL-EXPECTED-N
     PERFORM COUNT-ITEMS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   a bow drawn ten ticks and let go (looking straight ahead, over the ground)
     MOVE "/clear Alice" TO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE "/give Alice bow 1" TO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE "/give Alice arrow 5" TO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE 0 TO PL-YAW
     MOVE -10 TO PL-PITCH
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE 10 TO WS-ROUND
     CALL "CV-STEPS" USING CONVH WS-ROUND
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE 4 TO WS-ROUND
     CALL "CV-STEPS" USING CONVH WS-ROUND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE "arrow" TO WS-KEY-ITEM-NAME
     MOVE "acceptance bugusein: a bow held ten ticks with the right button and let go shoots one arrow" TO TL-CASE
     MOVE "arrow" TO WS-KEY-TYPE
     MOVE 1 TO TL-EXPECTED-N
     PERFORM COUNT-CORE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bugusein: and one arrow of the five is used up" TO TL-CASE
     MOVE 4 TO TL-EXPECTED-N
     PERFORM COUNT-ITEMS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   an ender pearl pressed on the ground is thrown
     MOVE "/clear Alice" TO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE "/give Alice ender_pearl 3" TO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE 0 TO PL-YAW
     MOVE 50 TO PL-PITCH
     PERFORM CLICK
     MOVE "ender_pearl" TO WS-KEY-ITEM-NAME
     MOVE "acceptance bugusein: an ender pearl pressed on the ground is thrown and the stack loses one" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     PERFORM COUNT-ITEMS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   the same pearl pressed on a crafting table: the table takes the click
     MOVE "/clear Alice" TO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE "/give Alice ender_pearl 3" TO WS-LINE
     PERFORM SAY-AND-STEP
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X)
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y) + 1
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z)
     MOVE WS-PX TO WS-EDIT-X
     MOVE WS-PY TO WS-EDIT-Y
     COMPUTE WS-PZ1 = WS-PZ + 1
     COMPUTE WS-PZ2 = WS-PZ + 2
     MOVE WS-PZ1 TO WS-EDIT-Z
     MOVE SPACES TO WS-LINE
     STRING "/setblock " FUNCTION TRIM(WS-EDIT-X) " " FUNCTION TRIM(WS-EDIT-Y) " " FUNCTION TRIM(WS-EDIT-Z) " air"
         DELIMITED BY SIZE INTO WS-LINE
     PERFORM SAY-AND-STEP
     MOVE WS-PZ2 TO WS-EDIT-Z
     MOVE SPACES TO WS-LINE
     STRING "/setblock " FUNCTION TRIM(WS-EDIT-X) " " FUNCTION TRIM(WS-EDIT-Y) " " FUNCTION TRIM(WS-EDIT-Z) " crafting_table"
         DELIMITED BY SIZE INTO WS-LINE
     PERFORM SAY-AND-STEP
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE 0 TO PL-YAW PL-PITCH
     MOVE "ender_pearl" TO WS-KEY-TYPE
     PERFORM COUNT-CORE
     MOVE WS-OBSERVE TO WS-BEFORE
     PERFORM CLICK
     MOVE "acceptance bugusein: a pearl pressed on a crafting table throws no new pearl" TO TL-CASE
     PERFORM COUNT-CORE
     MOVE WS-BEFORE TO TL-EXPECTED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "ender_pearl" TO WS-KEY-ITEM-NAME
     MOVE "acceptance bugusein: and the three pearls stay in the pack" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     PERFORM COUNT-ITEMS
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 FILL-AIR.
     COMPUTE WS-E1 = WS-FLOOR-Y + 1
     MOVE WS-LO-X TO WS-EDIT-X
     MOVE WS-E1 TO WS-EDIT-Y
     MOVE WS-LO-Z TO WS-EDIT-Z
     MOVE WS-HI-X TO WS-EDIT-X2
     MOVE WS-TOP-Y TO WS-EDIT-Y2
     MOVE WS-HI-Z TO WS-EDIT-Z2
     MOVE SPACES TO WS-LINE
     STRING "/fill " FUNCTION TRIM(WS-EDIT-X) " " FUNCTION TRIM(WS-EDIT-Y) " " FUNCTION TRIM(WS-EDIT-Z) " " FUNCTION TRIM(WS-EDIT-X2) " "
         FUNCTION TRIM(WS-EDIT-Y2) " " FUNCTION TRIM(WS-EDIT-Z2) " air" DELIMITED BY SIZE INTO WS-LINE
     PERFORM SAY-AND-STEP.

 FILL-STONE.
     MOVE WS-LO-X TO WS-EDIT-X
     MOVE WS-FLOOR-Y TO WS-EDIT-Y
     MOVE WS-LO-Z TO WS-EDIT-Z
     MOVE WS-HI-X TO WS-EDIT-X2
     MOVE WS-FLOOR-Y TO WS-EDIT-Y2
     MOVE WS-HI-Z TO WS-EDIT-Z2
     MOVE SPACES TO WS-LINE
     STRING "/fill " FUNCTION TRIM(WS-EDIT-X) " " FUNCTION TRIM(WS-EDIT-Y) " " FUNCTION TRIM(WS-EDIT-Z) " " FUNCTION TRIM(WS-EDIT-X2) " "
         FUNCTION TRIM(WS-EDIT-Y2) " " FUNCTION TRIM(WS-EDIT-Z2) " stone" DELIMITED BY SIZE INTO WS-LINE
     PERFORM SAY-AND-STEP.

 SAY-AND-STEP.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE TRAILING)) TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-ROUND
     CALL "CV-STEPS" USING CONVH WS-ROUND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE).

 CLICK.
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE CC-BUTTON-RIGHT TO WS-BUTTON
     MOVE CC-EV-BUTTON-DOWN TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE CC-EV-BUTTON-UP TO WS-DOWN
     CALL "CV-BUTTON-SET" USING CONVH WS-ALICE WS-BUTTON WS-DOWN
     MOVE 6 TO WS-ROUND
     CALL "CV-STEPS" USING CONVH WS-ROUND
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE).

 COUNT-CORE.
     MOVE "N" TO TL-MODE
     CALL "BUS-CORE" USING WS-NAME WS-KEY-TYPE WS-ROWS WS-KEY-ITEM WS-TOTAL
     MOVE WS-ROWS TO TL-OBSERVED-N WS-OBSERVE.

 COUNT-ITEMS.
     MOVE "N" TO TL-MODE
     CALL "BUS-ITEMS" USING WS-NAME WS-KEY-ITEM-NAME WS-TOTAL
     MOVE WS-TOTAL TO TL-OBSERVED-N.
 END PROGRAM ACC-BUGUSEIN-USE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUS-CORE.
*> USING name (PIC X(16)), short entity key (PIC X(24)), rows out (entities of that type in use), item out (unused), items out (the stack count of the held slot of that player).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-TYPE-KEY             PIC X(24).
 01 L-ROWS                 BINARY-LONG.
 01 L-ITEM                 BINARY-LONG.
 01 L-STACK                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-TYPE-KEY L-ROWS L-ITEM L-STACK.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(L-TYPE-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE 0 TO L-ROWS L-STACK
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > EN-COUNT
         IF EN-USED(WS-R) = 1 AND EN-TYPE(WS-R) = WS-TYPE
             ADD 1 TO L-ROWS
         END-IF
     END-PERFORM
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = L-NAME
             MOVE PL-SLOT-COUNT(WS-R, PL-HELD(WS-R) + 1) TO L-STACK
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BUS-CORE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUS-ITEMS.
*> USING name (PIC X(16)), short item key (PIC X(24)), total out: the count of that item over the 36 slots of that player.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-KEY                 PIC X(112).
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-STATUS              BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-NAME                 PIC X(16).
 01 L-ITEM-KEY             PIC X(24).
 01 L-TOTAL                BINARY-LONG.
 PROCEDURE DIVISION USING L-NAME L-ITEM-KEY L-TOTAL.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" FUNCTION TRIM(L-ITEM-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM WS-ITEM-ROW WS-STATUS
     MOVE 0 TO L-TOTAL
     PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > 64
         IF PL-USED(WS-R) = 1 AND PL-NAME(WS-R) = L-NAME
             PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 36
                 IF PL-SLOT-COUNT(WS-R, WS-S) > 0 AND PL-SLOT-ITEM(WS-R, WS-S) = WS-ITEM
                     ADD PL-SLOT-COUNT(WS-R, WS-S) TO L-TOTAL
                 END-IF
             END-PERFORM
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM BUS-ITEMS.
