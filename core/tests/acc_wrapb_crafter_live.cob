*> Acceptance test (wrap agent B round 4, T29572; docs/protocol/30-redstone-4 section 6, 31-block-entities-2 section 7): the crafter block crafts on a redstone pulse. A crafter whose nine slots show a
*> recipe crafts 4 ticks after it is powered (triggered and the crafting animation: `crafting` for 6 ticks), shrinks every non-empty slot by 1 and outputs the result into the container in front
*> (silently) or drops it as one item entity with the level events 1049 and 2010; a grid with no recipe plays 1050 and keeps its items; unpowering resets `triggered` and a new pulse crafts again;
*> a crafter placed against a powered block starts triggered and crafts. The standard world of the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPB-CRAFTER-LIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY CBLOCKS.
 COPY CITEMS.
 COPY BESTATE.
 01 WS-SKIP                BINARY-LONG.
 01 WS-WORLD-FOLDER        PIC X(64) VALUE "build/wrapb-crafter-live-world".
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-K                   PIC X(48).
 01 WS-PR                  PIC X(160).
 01 WS-ST                  BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-PROPS               PIC X(160).
 01 WS-FLAGS               BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-RESULT              BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXP                 PIC X(160).
 01 WS-OBS                 PIC X(160).
 01 WS-BE                  BINARY-LONG.
 01 WS-BE2                 BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LOG                 BINARY-LONG.
 01 WS-PLANKS              BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-COAL                BINARY-LONG.
 01 WS-COBBLE              BINARY-LONG.
 01 WS-TABLE               BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-SUM                 BINARY-LONG.
 01 WS-SUM-ED              PIC -(9)9.
 01 WS-COUNT-ED            PIC -(9)9.
 01 WS-HITS                BINARY-LONG.
 01 WS-HITS2               BINARY-LONG.
 01 WS-TEXT                PIC X(1024).
 01 WS-LINE                PIC X(1040).
 01 WS-DIGIT               PIC 9.
 01 WS-BELOW               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN-IN" USING WS-SKIP WS-WORLD-FOLDER
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance wrapb crafter live: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)
     PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 40
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
             MOVE 100 TO WS-Y
             MOVE "stone" TO WS-K MOVE SPACES TO WS-PR
             PERFORM PUT-BLOCK
             PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
                 MOVE "air" TO WS-K
                 PERFORM PUT-BLOCK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE 0.5 TO WS-PX
     MOVE WS-PX TO PL-X(WS-ROW)
     MOVE 106.0 TO PL-Y(WS-ROW)
     MOVE 60.5 TO PL-Z(WS-ROW)
     MOVE 10 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "oak_log" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-LOG
     MOVE "oak_planks" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-PLANKS
     MOVE "stone" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-STONE
     MOVE "coal" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-COAL
     MOVE "cobblestone" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-COBBLE
     MOVE "crafting_table" TO WS-K PERFORM FIND-ITEM MOVE WS-ITEM TO WS-TABLE

*>   A. a crafter facing east with 2 logs crafts one log into 4 planks 4 ticks after a redstone block powers it, drops them in front (events 1049 and 2010) and its animation ends 6 ticks later
     MOVE 0 TO WS-Z
     PERFORM MAKE-CRAFTER-EAST
     MOVE WS-LOG TO BE-SLOT-ITEM(WS-BE, 1) MOVE 2 TO BE-SLOT-COUNT(WS-BE, 1)
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     MOVE 2 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb crafter 30-4 6.2 a powered crafter is triggered at once and waits its 4 ticks: nothing crafted after 2 ticks" TO WS-CASE
     MOVE "2 crafting=false,orientation=east_up,triggered=true 0" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE 5 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb crafter 30-4 6.3 the crafter crafted: one log used, crafting is on, 4 planks lie in front" TO WS-CASE
     MOVE "1 crafting=true,orientation=east_up,triggered=true 4" TO WS-EXP
     PERFORM ASSERT-OBS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM COUNT-EVENTS
     MOVE "acceptance wrapb crafter 30-4 6.4 a drop into the world plays level events 1049 and 2010 (two Level Event packets)" TO WS-CASE
     MOVE "2" TO WS-EXP
     MOVE WS-HITS TO WS-SUM-ED
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS
     MOVE 12 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb crafter 31-2 7.3 six ticks after the craft the crafting property is false again; the crafter does not craft twice on one pulse" TO WS-CASE
     MOVE "1 crafting=false,orientation=east_up,triggered=true 4" TO WS-EXP
     PERFORM ASSERT-OBS

*>   B. a pulse after the power went away crafts again
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "air" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 3 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb crafter 30-4 6.2 without power the crafter is no longer triggered" TO WS-CASE
     MOVE "1 crafting=false,orientation=east_up,triggered=false 4" TO WS-EXP
     PERFORM ASSERT-OBS
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb crafter 30-4 6.2 the next pulse crafts the second log: 8 planks lie in front" TO WS-CASE
     MOVE "0 crafting=true,orientation=east_up,triggered=true 8" TO WS-EXP
     PERFORM ASSERT-OBS

*>   C. a chest in front takes the planks silently: no entity and no event
     MOVE 2 TO WS-Z
     PERFORM MAKE-CRAFTER-EAST
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "chest" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE WS-LOG TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM COUNT-EVENTS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb crafter 30-4 6.4 a chest in front takes all 4 planks: no entity in the world" TO WS-CASE
     MOVE "0 crafting=true,orientation=east_up,triggered=true 0" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE "acceptance wrapb crafter 30-4 6.4 the planks went into the chest's first slot" TO WS-CASE
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-SUM-ED
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     IF BE-SLOT-ITEM(WS-BE2, 1) = WS-PLANKS
         MOVE "4" TO WS-EXP
     ELSE
         MOVE "4 planks" TO WS-EXP
     END-IF
     PERFORM ASSERT-OBS
     MOVE "acceptance wrapb crafter 30-4 6.4 a container that took everything gets no level event" TO WS-CASE
     MOVE "0" TO WS-EXP
     MOVE WS-HITS TO WS-SUM-ED
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS

*>   D. no recipe: a stone and a coal are kept, one failure click (event 1050), the crafter is triggered
     MOVE 4 TO WS-Z
     PERFORM MAKE-CRAFTER-EAST
     MOVE WS-STONE TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE WS-COAL TO BE-SLOT-ITEM(WS-BE, 5) MOVE 3 TO BE-SLOT-COUNT(WS-BE, 5)
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM COUNT-EVENTS
     PERFORM OBS-CRAFTER
     MOVE "acceptance wrapb crafter 30-4 6.3 no recipe: the slots are untouched, crafting stays off, nothing is dropped" TO WS-CASE
     MOVE "1 crafting=false,orientation=east_up,triggered=true 0" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE "acceptance wrapb crafter 30-4 6.3 no recipe: the coal slot keeps its 3" TO WS-CASE
     MOVE "3" TO WS-EXP
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-SUM-ED
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS
     MOVE "acceptance wrapb crafter 30-4 6.3 no recipe: one Level Event (1050)" TO WS-CASE
     MOVE "1" TO WS-EXP
     MOVE WS-HITS TO WS-SUM-ED
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS

*>   E. a shaped recipe: four planks in the slots 1, 2, 4 and 5 (a 2 x 2 square) make one crafting table, and every slot shrinks by 1
     MOVE 6 TO WS-Z
     PERFORM MAKE-CRAFTER-EAST
     MOVE WS-PLANKS TO BE-SLOT-ITEM(WS-BE, 1) MOVE 4 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE WS-PLANKS TO BE-SLOT-ITEM(WS-BE, 2) MOVE 4 TO BE-SLOT-COUNT(WS-BE, 2)
     MOVE WS-PLANKS TO BE-SLOT-ITEM(WS-BE, 4) MOVE 4 TO BE-SLOT-COUNT(WS-BE, 4)
     MOVE WS-PLANKS TO BE-SLOT-ITEM(WS-BE, 5) MOVE 4 TO BE-SLOT-COUNT(WS-BE, 5)
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE WS-TABLE TO WS-ITEM
     PERFORM SUM-ENTITIES-OF
     MOVE "acceptance wrapb crafter 13 3.2 a 2 x 2 square of planks crafts one crafting table: it lies in front" TO WS-CASE
     MOVE "1" TO WS-EXP
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS
     MOVE "acceptance wrapb crafter 30-4 6.3 every non-empty slot shrank by one: 3 3 0 3 3" TO WS-CASE
     MOVE "33033" TO WS-EXP
     MOVE SPACES TO WS-OBS
     MOVE 1 TO WS-I
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-DIGIT MOVE WS-DIGIT TO WS-OBS(1:1)
     MOVE BE-SLOT-COUNT(WS-BE, 2) TO WS-DIGIT MOVE WS-DIGIT TO WS-OBS(2:1)
     MOVE BE-SLOT-COUNT(WS-BE, 3) TO WS-DIGIT MOVE WS-DIGIT TO WS-OBS(3:1)
     MOVE BE-SLOT-COUNT(WS-BE, 4) TO WS-DIGIT MOVE WS-DIGIT TO WS-OBS(4:1)
     MOVE BE-SLOT-COUNT(WS-BE, 5) TO WS-DIGIT MOVE WS-DIGIT TO WS-OBS(5:1)
     PERFORM ASSERT-OBS

*>   F. a full chest in front takes nothing: the planks are dropped (events 1049 and 2010)
     MOVE 8 TO WS-Z
     PERFORM MAKE-CRAFTER-EAST
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "chest" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 27
         MOVE WS-COBBLE TO BE-SLOT-ITEM(WS-BE2, WS-I) MOVE 64 TO BE-SLOT-COUNT(WS-BE2, WS-I)
     END-PERFORM
     MOVE WS-LOG TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     CALL "TEST-DRAIN-IDS" USING WS-ALICE WS-TEXT
     PERFORM COUNT-EVENTS
*>   the item spawns inside the chest's cell and is pushed out of it to the north (z 7.5): one row below counts
     MOVE 1 TO WS-BELOW
     PERFORM OBS-CRAFTER
     MOVE 0 TO WS-BELOW
     MOVE "acceptance wrapb crafter 30-4 6.4 a full chest refuses: the 4 planks are dropped in front" TO WS-CASE
     MOVE "0 crafting=true,orientation=east_up,triggered=true 4" TO WS-EXP
     PERFORM ASSERT-OBS
     MOVE "acceptance wrapb crafter 30-4 6.4 the drop plays events 1049 and 2010" TO WS-CASE
     MOVE "2" TO WS-EXP
     MOVE WS-HITS TO WS-SUM-ED
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS

*>   G. a crafter in front of a crafter: one item at a time through the fairness rule, one plank in each of the first four slots
     MOVE 10 TO WS-Z
     PERFORM MAKE-CRAFTER-EAST
     MOVE WS-LOG TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 4 TO WS-X MOVE 101 TO WS-Y MOVE "crafter" TO WS-K MOVE "crafting=false,orientation=up_north,triggered=false" TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE SPACES TO WS-OBS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9
         MOVE BE-SLOT-COUNT(WS-BE2, WS-I) TO WS-DIGIT
         MOVE WS-DIGIT TO WS-OBS(WS-I:1)
     END-PERFORM
     MOVE "acceptance wrapb crafter 30-4 6.4 path A: a crafter in front takes the planks one by one under its fairness rule" TO WS-CASE
     MOVE "111100000" TO WS-EXP
     PERFORM ASSERT-OBS

*>   H. a crafter placed already powered (the state REDSTONE-PLACE-STATE gives it) crafts without a neighbour change
     MOVE 12 TO WS-Z
     PERFORM CLEAR-ROW
     PERFORM POWER-ON
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "crafter" TO WS-K MOVE "crafting=false,orientation=east_up,triggered=false" TO WS-PR
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     CALL "REDSTONE-PLACE-STATE" USING WS-DIM WS-X WS-Y WS-Z WS-ST
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-LOG TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE WS-PLANKS TO WS-ITEM
     PERFORM SUM-ENTITIES-OF
     PERFORM READ-PROPS
     MOVE "acceptance wrapb crafter 30-4 6.1 a crafter placed against a powered block starts triggered and crafts (4 planks)" TO WS-CASE
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-PROPS) " " FUNCTION TRIM(WS-SUM-ED) DELIMITED BY SIZE INTO WS-OBS
     MOVE "crafting=true,orientation=east_up,triggered=true 4" TO WS-EXP
     PERFORM ASSERT-OBS

*>   I. the block entity is gone before the tick: nothing is crafted and nothing is dropped
     MOVE 14 TO WS-Z
     PERFORM MAKE-CRAFTER-EAST
     MOVE WS-LOG TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     PERFORM POWER-ON
     MOVE 0 TO BE-USED(WS-BE)
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE WS-PLANKS TO WS-ITEM
     PERFORM SUM-ENTITIES-OF
     MOVE "acceptance wrapb crafter 30-4 6.3 without a block entity the scheduled tick crafts nothing" TO WS-CASE
     MOVE "0" TO WS-EXP
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS

*>   J. a crafter facing down puts the planks into the chest below it (the container looks back through its top face)
     MOVE 16 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "chest" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 102 TO WS-Y MOVE "crafter" TO WS-K MOVE "crafting=false,orientation=down_north,triggered=false" TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-LOG TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     MOVE 2 TO WS-X MOVE 102 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "acceptance wrapb crafter 30-4 6.4 a crafter facing down fills the chest below it with the 4 planks" TO WS-CASE
     MOVE "4" TO WS-EXP
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-SUM-ED
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS

*>   K. a crafter facing up puts the planks into the chest above it
     MOVE 18 TO WS-Z
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 102 TO WS-Y MOVE "chest" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE2
     MOVE 101 TO WS-Y MOVE "crafter" TO WS-K MOVE "crafting=false,orientation=up_north,triggered=false" TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE
     MOVE WS-LOG TO BE-SLOT-ITEM(WS-BE, 1) MOVE 1 TO BE-SLOT-COUNT(WS-BE, 1)
     PERFORM POWER-ON
     MOVE 8 TO WS-TICKS PERFORM RUN-TICKS
     MOVE "acceptance wrapb crafter 30-4 6.4 a crafter facing up fills the chest above it with the 4 planks" TO WS-CASE
     MOVE "4" TO WS-EXP
     MOVE BE-SLOT-COUNT(WS-BE2, 1) TO WS-SUM-ED
     MOVE FUNCTION TRIM(WS-SUM-ED) TO WS-OBS
     PERFORM ASSERT-OBS
     STOP RUN.

 MAKE-CRAFTER-EAST.
*>   a crafter facing east at (3, 101, WS-Z) with the cells of the row clear, its block entity in WS-BE; the power block of POWER-ON is the cell (2, 101, WS-Z)
     PERFORM CLEAR-ROW
     MOVE 3 TO WS-X MOVE 101 TO WS-Y MOVE "crafter" TO WS-K MOVE "crafting=false,orientation=east_up,triggered=false" TO WS-PR PERFORM PUT-BLOCK
     CALL "BE-FIND" USING WS-DIM WS-X WS-Y WS-Z WS-BE.

 POWER-ON.
     MOVE 2 TO WS-X MOVE 101 TO WS-Y MOVE "redstone_block" TO WS-K MOVE SPACES TO WS-PR PERFORM PUT-BLOCK.

 OBS-CRAFTER.
*>   "<the count of slot 1> <the crafter's triggered and crafting properties> <the planks entities in the row>" of the crafter at (3, 101, WS-Z)
     MOVE 3 TO WS-X MOVE 101 TO WS-Y
     PERFORM READ-PROPS
     MOVE WS-PLANKS TO WS-ITEM
     PERFORM SUM-ENTITIES-OF
     MOVE BE-SLOT-COUNT(WS-BE, 1) TO WS-COUNT-ED
     MOVE SPACES TO WS-OBS
     STRING FUNCTION TRIM(WS-COUNT-ED) " " DELIMITED BY SIZE
         FUNCTION TRIM(WS-PROPS) " " DELIMITED BY SIZE FUNCTION TRIM(WS-SUM-ED) DELIMITED BY SIZE INTO WS-OBS.

 ASSERT-OBS.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXP TO TL-EXPECTED
     MOVE WS-OBS TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 SUM-ENTITIES-OF.
*>   the item entities of item WS-ITEM within the row WS-Z (and WS-BELOW rows before it): the count in WS-SUM and WS-SUM-ED
     MOVE 0 TO WS-SUM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM AND EN-ITEM(WS-I) = WS-ITEM
                 AND EN-Z(WS-I) >= WS-Z - WS-BELOW AND EN-Z(WS-I) < WS-Z + 1
             ADD EN-ITEM-COUNT(WS-I) TO WS-SUM
         END-IF
     END-PERFORM
     MOVE WS-SUM TO WS-SUM-ED.

 COUNT-EVENTS.
*>   the Level Event packets (id 47) in the ids drained into WS-TEXT, a run "47x2" counting twice
     MOVE SPACES TO WS-LINE
     STRING " " FUNCTION TRIM(WS-TEXT) " " DELIMITED BY SIZE INTO WS-LINE
     MOVE 0 TO WS-HITS WS-HITS2
     INSPECT WS-LINE TALLYING WS-HITS FOR ALL " 47 "
     INSPECT WS-LINE TALLYING WS-HITS2 FOR ALL " 47x2 "
     COMPUTE WS-HITS = WS-HITS + 2 * WS-HITS2.

 READ-PROPS.
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-STATE
     CALL "BLOCKS-STATE-PROPS" USING WS-STATE WS-PROPS.

 CLEAR-ROW.
*>   air on x 0 to 8 at heights 101 to 104 of row WS-Z
     PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 8
         PERFORM VARYING WS-Y FROM 101 BY 1 UNTIL WS-Y > 104
             MOVE "air" TO WS-K MOVE SPACES TO WS-PR
             PERFORM PUT-BLOCK
         END-PERFORM
     END-PERFORM.

 PUT-BLOCK.
*>   the block of key WS-K and property pairs WS-PR at (WS-X, WS-Y, WS-Z), written with flags 3
     CALL "PT-STATE" USING WS-K WS-PR WS-ST
     CALL "LEVEL-SET-BLOCK" USING WS-DIM WS-X WS-Y WS-Z WS-ST WS-FLAGS WS-BUDGET WS-RESULT.

 RUN-TICKS.
     CALL "TEST-TICKS" USING WS-TICKS.

 FIND-ITEM.
     MOVE 0 TO WS-ITEM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
         IF IT-KEY(WS-I) = WS-K
             COMPUTE WS-ITEM = WS-I - 1
         END-IF
     END-PERFORM.

 END PROGRAM ACC-WRAPB-CRAFTER-LIVE.

 COPY NOSPAWN.
 COPY CORETEST.
 COPY PORTALTEST.
