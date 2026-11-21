*> Implementation test (lane p49v; docs/protocol/19-mobs-land-friendly-and-neutral.md section 21 Copper golem): the row (health 12, speed 0.2, panic 1.5), the weathering clock (nextWeatheringTick:
*> -2 waxed, -1 unscheduled, 504000 to 552000 ticks a step, no step past oxidized), the statue roll (oxidized, air at its position, nextFloat <= 0.0058), honeycomb and axe (level events 3003, 3004, 3005),
*> lightning, shears on the antenna item, the item in the main hand taken back, any damage making it idle, the entity data (16 weathering state, 17 golem state) and the player-built golem
*> (a carved pumpkin on a copper block: the block becomes the copper chest of its type facing the pumpkin's way, the golem has the block's weathering level).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-19-21.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY RULES.
 COPY PROJSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-DOUBLE.
 01 WS-O                   BINARY-DOUBLE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-K48A                PIC X(48).
 01 WS-K48B                PIC X(48).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-M                   BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-WEATHER             BINARY-LONG.
 01 WS-NEXT                BINARY-LONG.
 01 WS-NOW                 BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-AIR                 BINARY-LONG.
 01 WS-ROLL                BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-EVENT               BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-BY1                 BINARY-LONG.
 01 WS-PROP                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-FOUND               BINARY-LONG.
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-HONEY               BINARY-LONG.
 01 WS-SHEARS              BINARY-LONG.
 01 WS-AXE                 BINARY-LONG.
 01 WS-POPPY               BINARY-LONG.
 01 WS-INGOT               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-EXPECT-LEN          BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG VALUE 1.
 01 WS-CAUSE               BINARY-LONG.
 01 WS-BOLT                BINARY-LONG.
 01 WS-PIG-T               BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-LEVELS.
    05 FILLER              PIC X(36) VALUE "0copper_block                       ".
    05 FILLER              PIC X(36) VALUE "1exposed_copper                     ".
    05 FILLER              PIC X(36) VALUE "2weathered_copper                   ".
    05 FILLER              PIC X(36) VALUE "3oxidized_copper                    ".
    05 FILLER              PIC X(36) VALUE "0waxed_copper_block                 ".
    05 FILLER              PIC X(36) VALUE "1waxed_exposed_copper               ".
    05 FILLER              PIC X(36) VALUE "2waxed_weathered_copper             ".
    05 FILLER              PIC X(36) VALUE "3waxed_oxidized_copper              ".
 01 WS-LEVEL-TABLE REDEFINES WS-LEVELS.
    05 WS-LEVEL-ROW        OCCURS 8 TIMES.
       10 WS-LEVEL-WANT    PIC 9.
       10 WS-LEVEL-KEY     PIC X(35).
 01 WS-STONE-STATE         BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-HAND                BINARY-LONG VALUE 0.
 01 WS-SNEAK               BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-VISUAL              BINARY-LONG VALUE 1.
 01 WS-NOBODY              BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE PL-X(WS-PLAYER) = WS-X0 + 24.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-Z0 + 24.5
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     COMPUTE WS-Y = WS-FLOOR + 1
     MOVE 6000 TO CW-TIME
     MOVE 100000 TO CW-TICKS
     MOVE 2 TO BW-DIFFICULTY
     MOVE "minecraft:copper_golem" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE "minecraft:honeycomb" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-HONEY WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:shears" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-SHEARS WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:iron_axe" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-AXE WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:poppy" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-POPPY WS-ITEM-ROW WS-STATUS
     MOVE "minecraft:copper_ingot" TO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-INGOT WS-ITEM-ROW WS-STATUS
     MOVE "N" TO TL-MODE

     MOVE "acceptance US15 19§21 Copper golem: it is a mob row with 12 health, walk 88 and panic 198" TO WS-CASE
     COMPUTE WS-E = 12 * 1000000 + 88 * 1000 + 198
     MOVE 0 TO WS-O
     IF WS-M > 0
         COMPUTE WS-O = SM-HEALTH(WS-M) * 1000000 + SM-WALK-MILLI(WS-M) * 1000 + SM-PANIC-MILLI(WS-M)
     END-IF
     PERFORM CHECK-N

*>   The weathering clock: a step needs 504000 to 552000 ticks.
     MOVE 0 TO WS-DRAW
     CALL "CG-DELAY" USING WS-DRAW WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: the shortest step is 504000 ticks" TO WS-CASE
     MOVE 504000 TO WS-E
     MOVE WS-RESULT TO WS-O
     PERFORM CHECK-N
     MOVE 48000 TO WS-DRAW
     CALL "CG-DELAY" USING WS-DRAW WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: the longest step is 552000 ticks" TO WS-CASE
     MOVE 552000 TO WS-E
     MOVE WS-RESULT TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-WEATHER
     MOVE -1 TO WS-NEXT
     MOVE 1000 TO WS-NOW
     MOVE 7 TO WS-DRAW
     CALL "CG-WEATHER-STEP" USING WS-WEATHER WS-NEXT WS-NOW WS-DRAW WS-CHANGED
     MOVE "acceptance US15 19§21 Copper golem: an unscheduled golem gets now + 504000 + the draw" TO WS-CASE
     COMPUTE WS-E = 1000 + 504007
     MOVE WS-NEXT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 19§21 Copper golem: scheduling changes nothing else" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-WEATHER + WS-CHANGED
     PERFORM CHECK-N
     MOVE 505006 TO WS-NOW
     CALL "CG-WEATHER-STEP" USING WS-WEATHER WS-NEXT WS-NOW WS-DRAW WS-CHANGED
     MOVE "acceptance US15 19§21 Copper golem: one tick before the time nothing happens" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-WEATHER + WS-CHANGED
     PERFORM CHECK-N
     MOVE 505007 TO WS-NOW
     CALL "CG-WEATHER-STEP" USING WS-WEATHER WS-NEXT WS-NOW WS-DRAW WS-CHANGED
     MOVE "acceptance US15 19§21 Copper golem: at the time the state advances one step (exposed)" TO WS-CASE
     MOVE 11 TO WS-E
     COMPUTE WS-O = WS-WEATHER * 10 + WS-CHANGED
     PERFORM CHECK-N
     MOVE "acceptance US15 19§21 Copper golem: the timer grows by another 504000 + the draw" TO WS-CASE
     COMPUTE WS-E = 505007 + 504007
     MOVE WS-NEXT TO WS-O
     PERFORM CHECK-N
     MOVE 3 TO WS-WEATHER
     MOVE 500 TO WS-NEXT
     CALL "CG-WEATHER-STEP" USING WS-WEATHER WS-NEXT WS-NOW WS-DRAW WS-CHANGED
     MOVE "acceptance US15 19§21 Copper golem: an oxidized golem does not step further and keeps its timer" TO WS-CASE
     MOVE 3500 TO WS-E
     COMPUTE WS-O = WS-WEATHER * 1000 + WS-NEXT
     PERFORM CHECK-N
     MOVE 1 TO WS-WEATHER
     MOVE -2 TO WS-NEXT
     MOVE 99999999 TO WS-NOW
     CALL "CG-WEATHER-STEP" USING WS-WEATHER WS-NEXT WS-NOW WS-DRAW WS-CHANGED
     MOVE "acceptance US15 19§21 Copper golem: a waxed golem (-2) never weathers" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-WEATHER + WS-CHANGED * 10
     IF WS-NEXT = -2
         ADD 0 TO WS-O
     ELSE
         ADD 100 TO WS-O
     END-IF
     PERFORM CHECK-N

*>   The statue roll: oxidized, air at its position and nextFloat() <= 0.0058 (a draw of 0 to 999999 is at most 5800).
     MOVE 3 TO WS-WEATHER
     MOVE 1 TO WS-AIR
     MOVE 5800 TO WS-ROLL
     CALL "CG-STATUE-CHECK" USING WS-WEATHER WS-AIR WS-ROLL WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: an oxidized golem in air with a roll of 0.0058 becomes a statue" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-RESULT TO WS-O
     PERFORM CHECK-N
     MOVE 5801 TO WS-ROLL
     CALL "CG-STATUE-CHECK" USING WS-WEATHER WS-AIR WS-ROLL WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: a roll above 0.0058 does not" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-RESULT TO WS-O
     PERFORM CHECK-N
     MOVE 5800 TO WS-ROLL
     MOVE 0 TO WS-AIR
     CALL "CG-STATUE-CHECK" USING WS-WEATHER WS-AIR WS-ROLL WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: without air at its position it does not" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-RESULT TO WS-O
     PERFORM CHECK-N
     MOVE 1 TO WS-AIR
     MOVE 2 TO WS-WEATHER
     CALL "CG-STATUE-CHECK" USING WS-WEATHER WS-AIR WS-ROLL WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: a weathered one (not oxidized) does not" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-RESULT TO WS-O
     PERFORM CHECK-N

*>   Honeycomb waxes (3003), an axe unwaxes (3004) or scrapes one level (3005), a bolt steps back one level.
     MOVE -1 TO WS-NEXT
     CALL "CG-WAX" USING WS-NEXT WS-EVENT
     MOVE "acceptance US15 19§21 Copper golem: honeycomb on an unwaxed golem sets the timer to -2 (level event 3003)" TO WS-CASE
     MOVE 30031 TO WS-E
     COMPUTE WS-O = WS-EVENT * 10
     IF WS-NEXT = -2
         ADD 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "CG-WAX" USING WS-NEXT WS-EVENT
     MOVE "acceptance US15 19§21 Copper golem: honeycomb on a waxed golem does nothing" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-EVENT TO WS-O
     PERFORM CHECK-N
     MOVE 2 TO WS-WEATHER
     MOVE -2 TO WS-NEXT
     CALL "CG-AXE" USING WS-WEATHER WS-NEXT WS-EVENT
     MOVE "acceptance US15 19§21 Copper golem: an axe on a waxed golem unwaxes it (-1, event 3004), the state stays" TO WS-CASE
     COMPUTE WS-E = 3004 * 100 + 2 * 10 + 1
     COMPUTE WS-O = WS-EVENT * 100 + WS-WEATHER * 10 + (WS-NEXT + 2)
     PERFORM CHECK-N
     MOVE 3 TO WS-WEATHER
     MOVE 777 TO WS-NEXT
     CALL "CG-AXE" USING WS-WEATHER WS-NEXT WS-EVENT
     MOVE "acceptance US15 19§21 Copper golem: an axe on a weathered unwaxed golem steps back one level (event 3005, timer -1)" TO WS-CASE
     COMPUTE WS-E = 3005 * 100 + 2 * 10 + 0
     COMPUTE WS-O = WS-EVENT * 100 + WS-WEATHER * 10 + (WS-NEXT + 1)
     PERFORM CHECK-N
     MOVE 0 TO WS-WEATHER
     MOVE 777 TO WS-NEXT
     CALL "CG-AXE" USING WS-WEATHER WS-NEXT WS-EVENT
     MOVE "acceptance US15 19§21 Copper golem: an axe on an unaffected unwaxed golem does nothing" TO WS-CASE
     MOVE 777 TO WS-E
     COMPUTE WS-O = WS-NEXT + WS-EVENT
     PERFORM CHECK-N
     MOVE 2 TO WS-WEATHER
     MOVE 777 TO WS-NEXT
     CALL "CG-LIGHTNING" USING WS-WEATHER WS-NEXT WS-CHANGED
     MOVE "acceptance US15 19§21 Copper golem: a bolt resets the timer to -1 and steps back one level" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-WEATHER * 100 + (WS-NEXT + 1) * 10 + WS-CHANGED
     MOVE 101 TO WS-E
     PERFORM CHECK-N
     MOVE 0 TO WS-WEATHER
     MOVE 777 TO WS-NEXT
     CALL "CG-LIGHTNING" USING WS-WEATHER WS-NEXT WS-CHANGED
     MOVE "acceptance US15 19§21 Copper golem: a bolt on an unaffected golem changes nothing" TO WS-CASE
     MOVE 777 TO WS-E
     COMPUTE WS-O = WS-NEXT + WS-CHANGED
     PERFORM CHECK-N

*>   In the world: the golem is created with state 0 and unscheduled; a tick schedules it.
     COMPUTE WS-X = WS-PX + 4
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-A
     MOVE "acceptance US15 19§21 Copper golem: a new golem is unaffected and idle" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = EN-CG-WEATHER(WS-A) + EN-CG-STATE(WS-A)
     PERFORM CHECK-N
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§21 Copper golem: its first tick schedules the next weathering within 504000 to 552000 ticks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-CG-NEXT(WS-A) >= CW-TICKS + 504000 AND EN-CG-NEXT(WS-A) <= CW-TICKS + 552000
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE CW-TICKS TO EN-CG-NEXT(WS-A)
     CALL "MOB-STEP" USING WS-A
     MOVE "acceptance US15 19§21 Copper golem: when the time has come a tick advances it to exposed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-CG-WEATHER(WS-A) TO WS-O
     PERFORM CHECK-N

*>   Entity data: 16 weathering state and 17 golem state, both VarInt enums, always sent as a pair.
     MOVE 3 TO EN-CG-STATE(WS-A)
     CALL "MOB-DATA-VALUES" USING WS-A WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US15 19§21 Copper golem: a copper golem always needs entity data" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-NEEDED TO WS-O
     PERFORM CHECK-N
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-A TP-BUFFER
     MOVE 8 TO WS-EXPECT-LEN
     IF EN-ID(WS-A) < 128
         ADD 1 TO WS-EXPECT-LEN
     ELSE
         ADD 2 TO WS-EXPECT-LEN
     END-IF
     MOVE "acceptance US15 19§21 Copper golem: the data are index 16 (3 bytes), index 17 (3 bytes) and the end marker, no baby entry" TO WS-CASE
     MOVE WS-EXPECT-LEN TO WS-E
     MOVE TP-LENGTH TO WS-O
     PERFORM CHECK-N
     CALL "PB-FREE" USING TP-BUFFER
     MOVE 0 TO EN-CG-STATE(WS-A)

*>   Any damage makes the golem idle again.
     MOVE 3 TO EN-CG-STATE(WS-A)
     MOVE 20 TO PL-HEALTH(WS-PLAYER)
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-A WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "acceptance US15 19§21 Copper golem: a hit resets the golem state to idle" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-CG-STATE(WS-A) TO WS-O
     PERFORM CHECK-N

*>   A bolt steps a weathered golem back one level, once per bolt.
     MOVE 2 TO EN-CG-WEATHER(WS-A)
     MOVE 5000 TO EN-CG-NEXT(WS-A)
     MOVE EN-X(WS-A) TO WS-X
     CALL "LIGHTNING-SPAWN" USING WS-DIM WS-X WS-Y WS-PZ WS-VISUAL WS-BOLT
     CALL "PJ-FIND" USING EN-ID(WS-BOLT) WS-SLOT
     CALL "LIGHTNING-HIT" USING WS-SLOT WS-BOLT WS-A WS-NOBODY
     MOVE "acceptance US15 19§21 Copper golem: a bolt resets the timer to -1 and steps the golem back to exposed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-CG-WEATHER(WS-A) = 1 AND EN-CG-NEXT(WS-A) = -1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "LIGHTNING-HIT" USING WS-SLOT WS-BOLT WS-A WS-NOBODY
     MOVE "acceptance US15 19§21 Copper golem: the same bolt does not step it back twice" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-CG-WEATHER(WS-A) TO WS-O
     PERFORM CHECK-N
     MOVE 12 TO EN-HEALTH(WS-A)
     MOVE 0 TO EN-CG-WEATHER(WS-A)

*>   Interaction. Hand item: a player with any item takes it (it is thrown out, the hand is cleared).
     MOVE WS-POPPY TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE WS-INGOT TO EN-ITEM(WS-A)
     MOVE 1 TO EN-ITEM-COUNT(WS-A)
     PERFORM COUNT-INGOTS
     MOVE WS-N TO WS-I
     CALL "CG-USE" USING WS-PLAYER WS-A WS-USED
     PERFORM COUNT-INGOTS
     MOVE "acceptance US15 19§21 Copper golem: an item in its hand is thrown out when a player right-clicks, the hand is empty" TO WS-CASE
     MOVE 1101 TO WS-E
     COMPUTE WS-O = WS-USED * 1000 + (WS-N - WS-I) * 100 + EN-ITEM-COUNT(WS-A) * 10 + 1
     PERFORM CHECK-N
*>   Shears with an item in the antenna slot (equipment slot SADDLE): it comes out 1.5 above the golem, the slot is empty.
     MOVE WS-SHEARS TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE WS-POPPY TO EN-CG-ANT(WS-A)
     MOVE 0 TO WS-N
     CALL "CG-USE" USING WS-PLAYER WS-A WS-USED
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-ITEM(WS-J) = WS-POPPY AND EN-ITEM-COUNT(WS-J) > 0
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance US15 19§21 Copper golem: shears take the antenna item (dropped) and empty the slot" TO WS-CASE
     MOVE 1101 TO WS-E
     COMPUTE WS-O = WS-USED * 1000 + WS-N * 100 + EN-CG-ANT(WS-A) * 10 + 1
     PERFORM CHECK-N
     MOVE "acceptance US15 19§21 Copper golem: shears without an antenna item do nothing" TO WS-CASE
     MOVE 0 TO WS-E
     CALL "CG-USE" USING WS-PLAYER WS-A WS-USED
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
*>   Honeycomb and an axe change the timer; the stack of honeycomb loses one.
     MOVE WS-HONEY TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 2 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 0 TO EN-CG-WEATHER(WS-A)
     MOVE -1 TO EN-CG-NEXT(WS-A)
     CALL "CG-USE" USING WS-PLAYER WS-A WS-USED
     MOVE "acceptance US15 19§21 Copper golem: honeycomb waxes the golem and one honeycomb is used" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-USED = 1 AND EN-CG-NEXT(WS-A) = -2 AND PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1) = 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "CG-USE" USING WS-PLAYER WS-A WS-USED
     MOVE "acceptance US15 19§21 Copper golem: a second honeycomb on a waxed golem is not used" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N
     MOVE WS-AXE TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 1 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 2 TO EN-CG-WEATHER(WS-A)
     CALL "CG-USE" USING WS-PLAYER WS-A WS-USED
     MOVE "acceptance US15 19§21 Copper golem: an axe on the waxed golem unwaxes it and keeps its level" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-USED = 1 AND EN-CG-NEXT(WS-A) = -1 AND EN-CG-WEATHER(WS-A) = 2
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "CG-USE" USING WS-PLAYER WS-A WS-USED
     MOVE "acceptance US15 19§21 Copper golem: the axe again scrapes a level" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-USED = 1 AND EN-CG-NEXT(WS-A) = -1 AND EN-CG-WEATHER(WS-A) = 1
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE 0 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     CALL "CG-USE" USING WS-PLAYER WS-A WS-USED
     MOVE "acceptance US15 19§21 Copper golem: an empty hand does nothing here" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-USED TO WS-O
     PERFORM CHECK-N

*>   The statue: the entity goes, an oxidized statue block stands in its place, what it carried drops.
     MOVE "minecraft:air" TO WS-KEY
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-A))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-A))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-A))
     MOVE WS-INGOT TO EN-ITEM(WS-A)
     MOVE 1 TO EN-ITEM-COUNT(WS-A)
     MOVE 3 TO EN-CG-WEATHER(WS-A)
     MOVE 0 TO EN-YAW(WS-A)
     PERFORM COUNT-INGOTS
     MOVE WS-N TO WS-I
     CALL "CG-STATUE-MAKE" USING WS-A
     PERFORM COUNT-INGOTS
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE "acceptance US15 19§21 Copper golem: an oxidized golem becomes an oxidized_copper_golem_statue block" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     MOVE CB-KEY(WS-BLOCK) TO WS-K48A
     CALL "KEY-BARE" USING WS-K48A WS-K48B
     IF WS-K48B = "oxidized_copper_golem_statue"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§21 Copper golem: the statue replaces the entity and what it carried drops" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = EN-USED(WS-A) * 100 + (WS-N - WS-I)
     PERFORM CHECK-N
     MOVE "facing" TO WS-PROP
     MOVE 1 TO WS-FOUND
     CALL "BLOCK-STATE-PROP" USING WS-FOUND WS-STATE WS-PROP WS-TEXT WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: a golem with yaw 0 (facing south) gives a statue facing south" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TEXT = "south"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N

*>   Through a real Interact packet: honeycomb in the main hand waxes a golem standing next to the player.
     COMPUTE WS-X = WS-PX + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-C
     MOVE WS-HONEY TO PL-SLOT-ITEM(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE 3 TO PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1)
     MOVE -1 TO EN-CG-NEXT(WS-C)
     CALL "TEST-INTERACT" USING PL-CONN(WS-PLAYER) EN-ID(WS-C) WS-HAND WS-SNEAK
     MOVE "acceptance US15 19§21 Copper golem: an Interact packet with honeycomb waxes it (timer -2) and uses one honeycomb" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF EN-CG-NEXT(WS-C) = -2 AND PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1) = 2
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-C

*>   Another species does not answer to the golem's interaction.
     MOVE "minecraft:pig" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-PIG-T WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-X = WS-PX + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-PIG-T WS-X WS-Y WS-PZ WS-YAW WS-C
     CALL "TEST-INTERACT" USING PL-CONN(WS-PLAYER) EN-ID(WS-C) WS-HAND WS-SNEAK
     MOVE "acceptance US15 19§21 Copper golem: honeycomb on a pig is not used by the golem's rules" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE PL-SLOT-COUNT(WS-PLAYER, PL-HELD(WS-PLAYER) + 1) TO WS-O
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-C

*>   Statues face the way the golem looks (yaw 90 is west, 270 east); the antenna item drops too.
     COMPUTE WS-X = WS-PX + 6
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-C
     MOVE 90 TO EN-YAW(WS-C)
     MOVE WS-POPPY TO EN-CG-ANT(WS-C)
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-C))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-C))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-C))
     CALL "CG-STATUE-MAKE" USING WS-C
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "facing" TO WS-PROP
     MOVE 1 TO WS-FOUND
     CALL "BLOCK-STATE-PROP" USING WS-FOUND WS-STATE WS-PROP WS-TEXT WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: yaw 90 gives a statue facing west" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TEXT = "west"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     COMPUTE WS-X = WS-PX + 8
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-C
     MOVE 270 TO EN-YAW(WS-C)
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-C))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-C))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-C))
     CALL "CG-STATUE-MAKE" USING WS-C
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-FOUND WS-STATE WS-PROP WS-TEXT WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: yaw 270 gives a statue facing east" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TEXT = "east"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     COMPUTE WS-X = WS-PX + 10
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-C
     MOVE 180 TO EN-YAW(WS-C)
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-C))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-C))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-C))
     CALL "CG-STATUE-MAKE" USING WS-C
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     CALL "BLOCK-STATE-PROP" USING WS-FOUND WS-STATE WS-PROP WS-TEXT WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: yaw 180 gives a statue facing north" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TEXT = "north"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N

*>   An oxidized, waxed golem (no weathering) in air turns into a statue within a few thousand ticks (0.58 percent a tick); in a block cell it never does.
     COMPUTE WS-X = WS-PX + 12
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-PZ WS-YAW WS-C
     MOVE 3 TO EN-CG-WEATHER(WS-C)
     MOVE -2 TO EN-CG-NEXT(WS-C)
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-C))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-C))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-C))
     MOVE "minecraft:short_grass" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STONE-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STONE-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 1500
         MOVE WS-X TO EN-X(WS-C)
         MOVE WS-Y TO EN-Y(WS-C)
         MOVE WS-PZ TO EN-Z(WS-C)
         CALL "MOB-STEP" USING WS-C
     END-PERFORM
     MOVE "acceptance US15 19§21 Copper golem: in a short grass cell (not air, no suffocation) an oxidized golem stays an entity for 1500 ticks" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE EN-USED(WS-C) TO WS-O
     PERFORM CHECK-N
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6000 OR EN-USED(WS-C) = 0
         MOVE WS-X TO EN-X(WS-C)
         MOVE WS-Y TO EN-Y(WS-C)
         MOVE WS-PZ TO EN-Z(WS-C)
         CALL "MOB-STEP" USING WS-C
     END-PERFORM
     MOVE "acceptance US15 19§21 Copper golem: in air it becomes a statue within 6000 ticks" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE EN-USED(WS-C) TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE CB-KEY(WS-BLOCK) TO WS-K48A
     CALL "KEY-BARE" USING WS-K48A WS-K48B
     MOVE "acceptance US15 19§21 Copper golem: the statue stands in the cell it left" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-K48B = "oxidized_copper_golem_statue"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N

*>   Built by a player: all eight blocks of the copper tag, each with a pumpkin on top; a pumpkin over air builds nothing.
     COMPUTE WS-BY = WS-FLOOR + 1
     COMPUTE WS-BY1 = WS-BY + 1
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > 8
         COMPUTE WS-BX = WS-X0 + 12 + WS-D
         COMPUTE WS-BZ = WS-Z0 + 10
         MOVE SPACES TO WS-KEY
         STRING "minecraft:" DELIMITED BY SIZE WS-LEVEL-KEY(WS-D) DELIMITED BY SPACE INTO WS-KEY
         CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         MOVE "minecraft:carved_pumpkin" TO WS-KEY
         CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY1 WS-BZ WS-STATE
         MOVE 0 TO WS-B
         CALL "GOLEM-BUILD" USING WS-DIM WS-BX WS-BY1 WS-BZ
         PERFORM COUNT-GOLEMS
         MOVE "acceptance US15 19§21 Copper golem: each copper block builds a golem of its level (see the next case for the block)" TO WS-CASE
         MOVE WS-LEVEL-WANT(WS-D) TO WS-E
         MOVE 99 TO WS-O
         IF WS-B > 0
             MOVE EN-CG-WEATHER(WS-B) TO WS-O
         END-IF
         PERFORM CHECK-N
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE CB-KEY(WS-BLOCK) TO WS-K48A
         CALL "KEY-BARE" USING WS-K48A WS-K48B
         MOVE "acceptance US15 19§21 Copper golem: the block of the tag becomes the chest of the same type (name ends in _chest)" TO WS-CASE
         MOVE 1 TO WS-E
         MOVE 0 TO WS-O
         IF WS-K48B(FUNCTION LENGTH(FUNCTION TRIM(WS-K48B TRAILING)) - 5:6) = "_chest"
             MOVE 1 TO WS-O
         END-IF
         PERFORM CHECK-N
     END-PERFORM
*>   A pumpkin with air below it builds nothing.
     COMPUTE WS-BX = WS-X0 + 30
     MOVE 0 TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "minecraft:carved_pumpkin" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY1 WS-BZ WS-STATE
     PERFORM COUNT-GOLEMS
     MOVE WS-N TO WS-I
     CALL "GOLEM-BUILD" USING WS-DIM WS-BX WS-BY1 WS-BZ
     PERFORM COUNT-GOLEMS
     MOVE "acceptance US15 19§21 Copper golem: a pumpkin over air builds nothing" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-N - WS-I
     PERFORM CHECK-N

*>   Built by a player: a carved pumpkin on a copper block (any weathering level, waxed or not).
     COMPUTE WS-BX = WS-X0 + 5
     COMPUTE WS-BY = WS-FLOOR + 1
     COMPUTE WS-BZ = WS-Z0 + 5
     COMPUTE WS-BY1 = WS-BY + 1
     MOVE "minecraft:waxed_weathered_copper" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "minecraft:carved_pumpkin" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     MOVE "facing" TO WS-PROP
     MOVE "east" TO WS-TEXT
     MOVE 2 TO WS-FOUND
     CALL "BLOCK-STATE-PROP" USING WS-FOUND WS-STATE WS-PROP WS-TEXT WS-RESULT
     MOVE WS-RESULT TO WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY1 WS-BZ WS-STATE
     MOVE 0 TO WS-N
     PERFORM COUNT-GOLEMS
     MOVE WS-N TO WS-I
     CALL "GOLEM-BUILD" USING WS-DIM WS-BX WS-BY1 WS-BZ
     PERFORM COUNT-GOLEMS
     MOVE "acceptance US15 19§21 Copper golem: a carved pumpkin on a copper block makes one golem" TO WS-CASE
     MOVE 1 TO WS-E
     COMPUTE WS-O = WS-N - WS-I
     PERFORM CHECK-N
     MOVE "acceptance US15 19§21 Copper golem: the golem has the weathering level of the block (waxed weathered is weathered, 2) and is not waxed" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE 0 TO WS-O
     IF WS-B > 0
         COMPUTE WS-O = EN-CG-WEATHER(WS-B)
         IF EN-CG-NEXT(WS-B) = -2
             MOVE 99 TO WS-O
         END-IF
     END-IF
     PERFORM CHECK-N
     MOVE "acceptance US15 19§21 Copper golem: it appears at the pumpkin's block, 0.05 above its floor" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-B > 0
         IF EN-Y(WS-B) > WS-BY1 + 0.04 AND EN-Y(WS-B) < WS-BY1 + 0.06
             MOVE 1 TO WS-O
         END-IF
     END-IF
     PERFORM CHECK-N
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY1 WS-BZ WS-STATE
     MOVE "acceptance US15 19§21 Copper golem: the pumpkin is gone" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE WS-STATE TO WS-O
     PERFORM CHECK-N
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-BLOCK = CB-S-BLOCK(WS-STATE + 1) + 1
     MOVE "acceptance US15 19§21 Copper golem: the copper block becomes a waxed_weathered_copper_chest" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     MOVE CB-KEY(WS-BLOCK) TO WS-K48A
     CALL "KEY-BARE" USING WS-K48A WS-K48B
     IF WS-K48B = "waxed_weathered_copper_chest"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
     MOVE "facing" TO WS-PROP
     MOVE 1 TO WS-FOUND
     CALL "BLOCK-STATE-PROP" USING WS-FOUND WS-STATE WS-PROP WS-TEXT WS-RESULT
     MOVE "acceptance US15 19§21 Copper golem: the chest faces the pumpkin's way (east)" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE 0 TO WS-O
     IF WS-TEXT = "east"
         MOVE 1 TO WS-O
     END-IF
     PERFORM CHECK-N
*>   A carved pumpkin on a plain block builds nothing.
     COMPUTE WS-BX = WS-X0 + 8
     MOVE "minecraft:stone" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     MOVE "minecraft:jack_o_lantern" TO WS-KEY
     CALL "MS-TEST-STATE" USING WS-KEY WS-STATE
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY1 WS-BZ WS-STATE
     PERFORM COUNT-GOLEMS
     MOVE WS-N TO WS-I
     CALL "GOLEM-BUILD" USING WS-DIM WS-BX WS-BY1 WS-BZ
     PERFORM COUNT-GOLEMS
     MOVE "acceptance US15 19§21 Copper golem: a jack o'lantern on stone builds no golem" TO WS-CASE
     MOVE 0 TO WS-E
     COMPUTE WS-O = WS-N - WS-I
     PERFORM CHECK-N
     STOP RUN.

 COUNT-INGOTS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-ITEM(WS-J) = WS-INGOT AND EN-ITEM-COUNT(WS-J) > 0 AND EN-TYPE(WS-J) NOT = WS-TYPE
             ADD EN-ITEM-COUNT(WS-J) TO WS-N
         END-IF
     END-PERFORM.

 COUNT-GOLEMS.
     MOVE 0 TO WS-N
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > EN-COUNT
         IF EN-USED(WS-J) = 1 AND EN-TYPE(WS-J) = WS-TYPE
             ADD 1 TO WS-N
             MOVE WS-J TO WS-B
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-19-21.
 COPY CORETEST.
 COPY MOBSPTEST.
