*> Acceptance test of Pickup (T0348; docs/protocol/41-item-entity-physics.md section 4; FR-037): the pickup box (the player's box
*> inflated by 1.0 horizontally and 0.5 vertically, strict comparisons), the delay, the owner, Inventory.add (the selected slot
*> first, then the first slot with room, then the first free slot; damaged stacks do not stack; the survival partial transfer sends
*> nothing and keeps the rest; the creative player consumes the whole stack), the Take Item Entity packet, the statistic, the
*> restored patch, dead players, and merging (4.4). Alice stands at (4.5, 54, 8.5); the items lie around her feet.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ITEMPHYS-41-4.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CITEMPHYS.
 COPY CITEMS.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECTED            PIC X(1024).
 01 WS-OBSERVED            PIC X(1024).
 01 WS-TEXT                PIC X(1024).
 01 WS-T1                  PIC X(64).
 01 WS-A                   PIC X(16).
 01 WS-B                   PIC X(16).
 01 WS-C                   PIC X(16).
 01 WS-D                   PIC X(16).
 01 WS-DIM                 BINARY-LONG VALUE 1.
 01 WS-ITEM                BINARY-LONG VALUE 2.
 01 WS-OTHER-ITEM          BINARY-LONG VALUE 3.
 01 WS-COUNT               BINARY-LONG VALUE 10.
 01 WS-DELAY               BINARY-LONG VALUE 0.
 01 WS-VAR                 BINARY-LONG VALUE 0.
 01 WS-DAMAGED             BINARY-LONG VALUE 0.
 01 WS-DAMAGE              BINARY-LONG VALUE 5.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG VALUE 8.5.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-V3                  FLOAT-LONG VALUE 0.
 01 WS-DX                  FLOAT-LONG VALUE 0.
 01 WS-DY                  FLOAT-LONG VALUE 0.
 01 WS-CA                  BINARY-LONG.
 01 WS-CB                  BINARY-LONG.
 01 WS-RUN                 BINARY-LONG VALUE 1.
 01 WS-OWNERS              BINARY-LONG VALUE 0.
 01 WS-VARS                BINARY-LONG VALUE 0.
 01 WS-BREAK               BINARY-LONG VALUE 0.
 01 WS-K                   BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 0 TO PL-HELD(WS-PLAYER)

*>   4.1 The pickup box: x within 0.3 + 1.0 + 0.125 of the player, y from 0.5 below the feet to 0.5 above the head.
     PERFORM CLEAR-ALL
     MOVE 54 TO WS-Y
     MOVE 5.9 TO WS-X
     PERFORM SPAWN
     MOVE WS-ROW TO WS-ROW2
     MOVE 5.95 TO WS-X
     PERFORM SPAWN
     PERFORM TICK
     MOVE "acceptance US2 41§4 Pickup an item whose box meets the player's box inflated by 1.0 horizontally is picked up, one just "
         & "outside (strict comparison) is not" TO WS-CASE
     MOVE "picked left" TO WS-EXPECTED
     MOVE SPACES TO WS-OBSERVED
     IF EN-USED(WS-ROW2) = 0 AND EN-USED(WS-ROW) = 1
         MOVE "picked left" TO WS-OBSERVED
     END-IF
     PERFORM CHECK
     PERFORM CLEAR-ALL
     MOVE 4.5 TO WS-X
     MOVE 56.25 TO WS-Y
     PERFORM SPAWN
     MOVE WS-ROW TO WS-ROW2
     MOVE 56.4 TO WS-Y
     PERFORM SPAWN
     PERFORM TICK
     MOVE "acceptance US2 41§4 Pickup vertically the box reaches 0.5 above the player's head (56.3): an item at 56.25 is touched, "
         & "one at 56.4 is not" TO WS-CASE
     MOVE "picked left" TO WS-EXPECTED
     MOVE SPACES TO WS-OBSERVED
     IF EN-USED(WS-ROW2) = 0 AND EN-USED(WS-ROW) = 1
         MOVE "picked left" TO WS-OBSERVED
     END-IF
     PERFORM CHECK

*>   4.2 The pickup delay: delay 10 is not picked up on ticks 1 to 10, then on tick 11.
     PERFORM CLEAR-ALL
     MOVE 4.5 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 10 TO WS-DELAY
     PERFORM SPAWN
     MOVE 10 TO WS-N
     PERFORM TICKS
     MOVE EN-USED(WS-ROW) TO WS-I
     PERFORM TICK
     MOVE "acceptance US2 41§4 Pickup an item with delay 10 is not picked up on ticks 1 to 10 and is on tick 11" TO WS-CASE
     MOVE "1 0" TO WS-EXPECTED
     CALL "ITT-I" USING WS-I WS-A
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK
     MOVE 0 TO WS-DELAY

*>   The owner: only the owner picks the item up; the thrower field does not matter.
     PERFORM CLEAR-ALL
     PERFORM SPAWN
     MOVE 1 TO IP-I-HAS-OWNER(WS-ROW)
     MOVE "someone else    " TO IP-I-OWNER(WS-ROW)
     MOVE PL-ENTITY-ID(WS-PLAYER) TO IP-I-THROWER(WS-ROW)
     PERFORM TICK
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-A
     MOVE PL-UUID(WS-PLAYER) TO IP-I-OWNER(WS-ROW)
     PERFORM TICK
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-B
     MOVE "acceptance US2 41§4 Pickup an item with an owner is skipped by every other player and picked up by the owner, whether or "
         & "not the owner threw it" TO WS-CASE
     MOVE "1 0" TO WS-EXPECTED
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM CHECK

*>   Dead players pick nothing up.
     PERFORM CLEAR-ALL
     PERFORM SPAWN
     MOVE PS-DEAD TO PL-STATE(WS-PLAYER)
     PERFORM TICK
     MOVE PS-ALIVE TO PL-STATE(WS-PLAYER)
     MOVE "acceptance US2 41§4 Pickup a dead player picks nothing up" TO WS-CASE
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-OBSERVED
     MOVE "1" TO WS-EXPECTED
     PERFORM CHECK

*>   4.3 The selected slot first, then the first slot with room in index order: 10 items, the held slot 3 holds 60, slot 1 holds 10.
     PERFORM CLEAR-ALL
     MOVE 3 TO PL-HELD(WS-PLAYER)
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 4)
     MOVE 60 TO PL-SLOT-COUNT(WS-PLAYER, 4)
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 2)
     MOVE 10 TO PL-SLOT-COUNT(WS-PLAYER, 2)
     PERFORM SPAWN
     MOVE EN-ID(WS-ROW) TO WS-ID
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     PERFORM TICK
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "acceptance US2 41§4 Pickup Inventory.add fills the selected slot first (60 + 4 = 64) and puts the other 6 into the first "
         & "slot with room of the same item (10 + 6 = 16)" TO WS-CASE
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 4) WS-A
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 2) WS-B
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 1) WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "64 16 0" TO WS-EXPECTED
     PERFORM CHECK
     MOVE "acceptance US2 41§4 Pickup a taken stack sends Take Item Entity (collected id, collector id, the full count) to the "
         & "viewers, then Remove Entities, and awards item_picked_up with the count" TO WS-CASE
     CALL "ITT-I" USING WS-ID WS-A
     CALL "ITT-I" USING PL-ENTITY-ID(WS-PLAYER) WS-B
     MOVE SPACES TO WS-EXPECTED
     STRING "127(" FUNCTION TRIM(WS-A) "," FUNCTION TRIM(WS-B) ",10)" DELIMITED BY SIZE INTO WS-EXPECTED
     MOVE 0 TO WS-N
     INSPECT WS-TEXT TALLYING WS-N FOR ALL FUNCTION TRIM(WS-EXPECTED)
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-PICKED WS-ITEM WS-I
     CALL "ITT-I" USING WS-N WS-C
     CALL "ITT-I" USING WS-I WS-D
     MOVE SPACES TO WS-OBSERVED
     STRING "take " FUNCTION TRIM(WS-C) " picked " FUNCTION TRIM(WS-D) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "take 1 picked 10" TO WS-EXPECTED
     PERFORM CHECK
*>   A stack with a patch does not stack onto stacks without it: it takes the first free slot and keeps its patch (T3665).
     PERFORM CLEAR-ALL
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 4)
     MOVE 60 TO PL-SLOT-COUNT(WS-PLAYER, 4)
     MOVE 9 TO WS-VAR
     PERFORM SPAWN
     PERFORM TICK
     MOVE "acceptance US2 41§4 Pickup a stack with a patch handle does not stack onto an item without it: it takes the first free "
         & "slot and the pickup restores the patch" TO WS-CASE
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 4) WS-A
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 1) WS-B
     CALL "ITT-I" USING PL-SLOT-VAR(WS-PLAYER, 1) WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " var " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "60 10 var 9" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 0 TO WS-VAR
     MOVE 0 TO PL-HELD(WS-PLAYER)

*>   The selected slot of the same item with a stack of 10: the stack moves to the first slot with room by index when the held slot is
*>   full (slot 0 empty: first free slot after the matching slots).
     PERFORM CLEAR-ALL
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-OTHER-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-I)
         MOVE 64 TO PL-SLOT-COUNT(WS-PLAYER, WS-I)
     END-PERFORM
     MOVE 0 TO PL-SLOT-ITEM(WS-PLAYER, 8) PL-SLOT-COUNT(WS-PLAYER, 8)
     MOVE 0 TO PL-SLOT-ITEM(WS-PLAYER, 10) PL-SLOT-COUNT(WS-PLAYER, 10)
     PERFORM SPAWN
     PERFORM TICK
     MOVE "acceptance US2 41§4 Pickup with no slot holding the item the stack goes into the first free slot by index" TO WS-CASE
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 8) WS-A
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 10) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "10 0" TO WS-EXPECTED
     PERFORM CHECK

*>   Survival, room for 3 of 5: the 3 are added, add returns false, the entity keeps 2, no packet, no statistic.
     PERFORM CLEAR-ALL
     PERFORM FILL-OTHER
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 5)
     MOVE 61 TO PL-SLOT-COUNT(WS-PLAYER, 5)
     MOVE 5 TO WS-COUNT
     PERFORM SPAWN
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     PERFORM TICK
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "acceptance US2 41§4 Pickup in survival with room for only 3 of 5 the 3 stay in the inventory, the entity keeps 2 and no "
         & "Take Item Entity packet or statistic is produced" TO WS-CASE
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 5) WS-A
     CALL "ITT-I" USING EN-ITEM-COUNT(WS-ROW) WS-B
     MOVE 0 TO WS-N
     INSPECT WS-TEXT TALLYING WS-N FOR ALL "127("
     CALL "ITT-I" USING WS-N WS-C
     CALL "IP-STAT-GET" USING WS-PLAYER IP-STAT-PICKED WS-ITEM WS-I
     CALL "ITT-I" USING WS-I WS-D
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " take " FUNCTION TRIM(WS-C) " stat " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "64 2 take 0 stat 0" TO WS-EXPECTED
     PERFORM CHECK
*>   Survival, no room at all: nothing changes.
     MOVE 64 TO PL-SLOT-COUNT(WS-PLAYER, 5)
     PERFORM TICK
     MOVE "acceptance US2 41§4 Pickup in survival with a full inventory the item stays" TO WS-CASE
     CALL "ITT-I" USING EN-ITEM-COUNT(WS-ROW) WS-A
     MOVE WS-A TO WS-OBSERVED
     MOVE "2" TO WS-EXPECTED
     PERFORM CHECK
*>   Creative: the whole remaining stack is consumed even when only part fitted, and also with a full inventory.
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 61 TO PL-SLOT-COUNT(WS-PLAYER, 5)
     MOVE 5 TO EN-ITEM-COUNT(WS-ROW)
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     PERFORM TICK
     CALL "TEST-DRAIN-ENTITIES" USING WS-ALICE WS-TEXT
     MOVE "acceptance US2 41§4 Pickup in creative with room for only 3 of 5 the 3 are added and the whole stack is consumed, the "
         & "packet amount is 5" TO WS-CASE
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 5) WS-A
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-B
     MOVE 0 TO WS-N
     INSPECT WS-TEXT TALLYING WS-N FOR ALL ",5)"
     CALL "ITT-I" USING WS-N WS-C
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "64 0 1" TO WS-EXPECTED
     PERFORM CHECK
     PERFORM SPAWN
     PERFORM TICK
     MOVE "acceptance US2 41§4 Pickup in creative with a full inventory the item is consumed and nothing is added" TO WS-CASE
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-A
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 5) WS-B
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "0 64" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 0 TO PL-MODE(WS-PLAYER)

*>   A damaged stack never stacks: it takes the first free slot; the patch handle goes with it.
     PERFORM CLEAR-ALL
     CALL "SP-SET-DAMAGE" USING WS-DAMAGED WS-DAMAGE
     MOVE WS-ITEM TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE WS-DAMAGED TO PL-SLOT-VAR(WS-PLAYER, 1)
     MOVE 1 TO WS-COUNT
     MOVE WS-DAMAGED TO WS-VAR
     PERFORM SPAWN
     PERFORM TICK
     MOVE "acceptance US2 41§4 Pickup a damaged stack does not stack onto an equal damaged stack: it goes to the first free slot with "
         & "its patch handle" TO WS-CASE
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 1) WS-A
     CALL "ITT-I" USING PL-SLOT-COUNT(WS-PLAYER, 2) WS-B
     CALL "ITT-I" USING PL-SLOT-VAR(WS-PLAYER, 2) WS-C
     CALL "ITT-I" USING WS-DAMAGED WS-D
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " = " FUNCTION TRIM(WS-D)
         DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE SPACES TO WS-EXPECTED
     STRING "1 1 " FUNCTION TRIM(WS-D) " = " FUNCTION TRIM(WS-D) DELIMITED BY SIZE INTO WS-EXPECTED
     PERFORM CHECK
*>   Survival full inventory with a damaged stack: stays; creative: consumed.
     PERFORM FILL-OTHER
     PERFORM SPAWN
     PERFORM TICK
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-A
     MOVE 1 TO PL-MODE(WS-PLAYER)
     PERFORM TICK
     MOVE EN-USED(WS-ROW) TO WS-I
     CALL "ITT-I" USING WS-I WS-B
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE "acceptance US2 41§4 Pickup a damaged stack with no free slot stays in survival and is consumed in creative" TO WS-CASE
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED
     MOVE "1 0" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 0 TO WS-VAR

*>   4.4 Merging: two items within 0.5 horizontally merge into the entity with the larger count, whichever runs the pass; the delay
*>   becomes the larger and the age the smaller of the two.
     MOVE 0 TO WS-DX WS-DY
     MOVE 20 TO WS-CA
     MOVE 30 TO WS-CB
     MOVE 0.5 TO WS-DX
     MOVE 1 TO WS-RUN
     PERFORM MERGE-CASE
     MOVE "acceptance US2 41§4 Pickup when the 20-stack runs the merge pass the 30-stack absorbs it: 50 remains, the 20-entity is "
         & "discarded, delay max 7, age min 100" TO WS-CASE
     MOVE "0 1 0 50 7 100" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 2 TO WS-RUN
     PERFORM MERGE-CASE
     MOVE "acceptance US2 41§4 Pickup when the 30-stack runs the pass it absorbs the 20-stack: the same result" TO WS-CASE
     PERFORM CHECK
     MOVE 20 TO WS-CB
     MOVE 1 TO WS-RUN
     PERFORM MERGE-CASE
     MOVE "acceptance US2 41§4 Pickup on equal counts the other entity receives: this one is discarded" TO WS-CASE
     MOVE "0 1 0 40 7 100" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 40 TO WS-CA
     MOVE 30 TO WS-CB
     PERFORM MERGE-CASE
     MOVE "acceptance US2 41§4 Pickup stacks of 40 and 30 (70 above the maximum 64) do not merge" TO WS-CASE
     MOVE "1 1 40 30 3 500" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 20 TO WS-CA
     MOVE 0.8 TO WS-DX
     PERFORM MERGE-CASE
     MOVE "acceptance US2 41§4 Pickup items 0.8 apart horizontally are outside the 0.5 inflated box and do not merge" TO WS-CASE
     MOVE "1 1 20 30 3 500" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 0.5 TO WS-DX
     MOVE 0.3 TO WS-DY
     PERFORM MERGE-CASE
     MOVE "acceptance US2 41§4 Pickup items 0.3 apart vertically (more than the height 0.25) do not merge" TO WS-CASE
     PERFORM CHECK
     MOVE 0 TO WS-DY
     MOVE 1 TO WS-OWNERS
     PERFORM MERGE-CASE
     MOVE "acceptance US2 41§4 Pickup items with different owners do not merge" TO WS-CASE
     MOVE "1 1 20 30 3 500" TO WS-EXPECTED
     PERFORM CHECK
     MOVE 0 TO WS-OWNERS
     MOVE 1 TO WS-VARS
     PERFORM MERGE-CASE
     MOVE "acceptance US2 41§4 Pickup items with different patch handles do not merge" TO WS-CASE
     PERFORM CHECK
     MOVE 0 TO WS-VARS
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE WS-K TO WS-BREAK
         PERFORM MERGE-CASE
         CALL "ITT-I" USING WS-K WS-A
         MOVE SPACES TO WS-CASE
         STRING "acceptance US2 41§4 Pickup an item that is not mergeable (age 6000, delay 32767, age -32768 or a full stack, "
             "case " FUNCTION TRIM(WS-A) ") is not merged into" DELIMITED BY SIZE INTO WS-CASE
         EVALUATE WS-K
             WHEN 1 MOVE "1 1 20 30 3 6000" TO WS-EXPECTED
             WHEN 2 MOVE "1 1 20 30 32767 500" TO WS-EXPECTED
             WHEN 3 MOVE "1 1 20 30 3 -32768" TO WS-EXPECTED
             WHEN 4 MOVE "1 1 20 64 3 500" TO WS-EXPECTED
         END-EVALUATE
         PERFORM CHECK
     END-PERFORM
     STOP RUN.

 SPAWN.
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-V1 WS-V2 WS-V3 WS-ITEM WS-COUNT WS-DELAY WS-ROW
     MOVE WS-VAR TO IP-I-VAR(WS-ROW).

 TICK.
     MOVE 1 TO WS-N
     CALL "TEST-TICKS" USING WS-N.

 TICKS.
     CALL "TEST-TICKS" USING WS-N.

*> Removes every ground item and empties the inventory of Alice.
 CLEAR-ALL.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-TYPE(WS-I) = CR-LOOSE-ITEM
             CALL "ENTITY-REMOVE" USING WS-I
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE 0 TO PL-SLOT-ITEM(WS-PLAYER, WS-I) PL-SLOT-COUNT(WS-PLAYER, WS-I) PL-SLOT-VAR(WS-PLAYER, WS-I)
     END-PERFORM
     MOVE 0 TO IP-S-PICKED(WS-PLAYER, WS-ITEM + 1)
     MOVE 4.5 TO WS-X
     MOVE 54 TO WS-Y
     MOVE 8.5 TO WS-Z
     MOVE 10 TO WS-COUNT
     MOVE 0 TO WS-VAR WS-DELAY.

*> Every slot holds 64 of the other item.
 FILL-OTHER.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 36
         MOVE WS-OTHER-ITEM TO PL-SLOT-ITEM(WS-PLAYER, WS-I)
         MOVE 64 TO PL-SLOT-COUNT(WS-PLAYER, WS-I)
         MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, WS-I)
     END-PERFORM.

*> Two items A (count WS-CA, delay 7, age 100) and B (WS-CB, delay 3, age 500) WS-DX apart in x and WS-DY in y; WS-OWNERS 1 gives
*> them different owners, WS-VARS 1 different patches, WS-BREAK 1 to 4 makes B not mergeable (age 6000, delay 32767, age -32768,
*> count 64); WS-RUN 1 or 2 runs the pass of A or B. WS-OBSERVED: "usedA usedB countA countB delayB ageB".
 MERGE-CASE.
     PERFORM CLEAR-ALL
     MOVE 20.5 TO WS-X
     MOVE 100 TO WS-Y
     MOVE 20.5 TO WS-Z
     MOVE WS-CA TO WS-COUNT
     PERFORM SPAWN
     MOVE WS-ROW TO WS-ROW2
     MOVE 7 TO EN-DELAY(WS-ROW2)
     MOVE 100 TO EN-AGE(WS-ROW2)
     COMPUTE WS-X = 20.5 + WS-DX
     COMPUTE WS-Y = 100 + WS-DY
     MOVE WS-CB TO WS-COUNT
     PERFORM SPAWN
     MOVE 3 TO EN-DELAY(WS-ROW)
     MOVE 500 TO EN-AGE(WS-ROW)
     IF WS-OWNERS = 1
         MOVE 1 TO IP-I-HAS-OWNER(WS-ROW)
         MOVE "someone else    " TO IP-I-OWNER(WS-ROW)
     END-IF
     IF WS-VARS = 1
         MOVE 4 TO IP-I-VAR(WS-ROW)
     END-IF
     EVALUATE WS-BREAK
         WHEN 1 MOVE 6000 TO EN-AGE(WS-ROW)
         WHEN 2 MOVE 32767 TO EN-DELAY(WS-ROW)
         WHEN 3 MOVE -32768 TO EN-AGE(WS-ROW)
         WHEN 4 MOVE 64 TO EN-ITEM-COUNT(WS-ROW)
     END-EVALUATE
     IF WS-RUN = 1
         CALL "IP-MERGE" USING WS-ROW2
     ELSE
         CALL "IP-MERGE" USING WS-ROW
     END-IF
     MOVE EN-USED(WS-ROW2) TO WS-N
     CALL "ITT-I" USING WS-N WS-A
     MOVE EN-USED(WS-ROW) TO WS-N
     CALL "ITT-I" USING WS-N WS-B
     CALL "ITT-I" USING EN-ITEM-COUNT(WS-ROW2) WS-C
     CALL "ITT-I" USING EN-ITEM-COUNT(WS-ROW) WS-D
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) " " FUNCTION TRIM(WS-D) " "
         DELIMITED BY SIZE INTO WS-OBSERVED
     CALL "ITT-I" USING EN-DELAY(WS-ROW) WS-A
     CALL "ITT-I" USING EN-AGE(WS-ROW) WS-B
     MOVE FUNCTION TRIM(WS-OBSERVED) TO WS-TEXT
     MOVE SPACES TO WS-OBSERVED
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) DELIMITED BY SIZE INTO WS-OBSERVED.

 CHECK.
     CALL "ITT-CHECK" USING WS-CASE WS-EXPECTED WS-OBSERVED.
 END PROGRAM TEST-ITEMPHYS-41-4.

 COPY CORETEST.
 COPY ITEMTEST.
