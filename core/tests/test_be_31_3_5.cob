*> Test of 31-3 section 5, Decorated pots (core/src/be-31-3.cob; T0897): the sherd mapping, the insert rule with its fraction and pitch, the wobble event and its animation formulas, cracking and the saved keys.
*> Each case runs its statements and shows the items joined by single spaces ("n" integers, "f" floats x 1e6, "t" text up to a stored length).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-3-5.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-SHOW                PIC -(9)9.
 01 WS-PTR                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-OUT                 PIC X(8192).
 01 WS-CAPACITY            BINARY-LONG VALUE 8192.
 01 WS-T10                 BINARY-LONG VALUE 10.
 01 WS-FORM                BINARY-LONG VALUE 1.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-KEY                 PIC X(48).
 01 WS-NM                  PIC X(32).
 01 WS-NML                 BINARY-LONG.
 01 WS-SV                  PIC X(256).
 01 WS-SVL                 BINARY-LONG.
 01 WS-NV                  BINARY-LONG.
 01 WS-LV                  BINARY-DOUBLE.
 01 WS-LT                  BINARY-LONG.
 01 WS-LC                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-KP                  BINARY-LONG VALUE 0.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-A                 BINARY-LONG.
 01 WS-B                 BINARY-LONG.
 01 WS-C                 BINARY-LONG.
 01 WS-E                 BINARY-LONG.
 01 WS-F                 BINARY-LONG.
 01 WS-G                 BINARY-LONG.
 01 WS-H                 BINARY-LONG.
 01 WS-FA                FLOAT-LONG.
 01 WS-FB                FLOAT-LONG.
 01 WS-FC                FLOAT-LONG.
 01 WS-FD                FLOAT-LONG.
 01 WS-FE                FLOAT-LONG.
 01 WS-FF                FLOAT-LONG.
 01 WS-U16                PIC X(16) VALUE "0123456789abcdef".
 01 WS-V16                PIC X(16) VALUE "fedcba9876543210".
 01 WS-N24                PIC X(24).
 01 WS-N32                PIC X(32).
 01 WS-TX                 PIC X(384).
 01 WS-LINES.
    05 WS-LINE            OCCURS 4 TIMES.
       10 WS-LINE-LEN     BINARY-LONG.
       10 WS-LINE-TEXT    PIC X(384).
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "acceptance US12 31-3§5 Decorated pots: state (5.1): a new pot has no sherds and no item and saves no keys; the item key is absent for an empty pot" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: sherds (5.2): each side is an item template compound or a bare item id; absent sides stay plain; saved back as compounds (back, left, right, front order)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "sherds" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "back" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:brick" TO WS-SV
     MOVE 15 TO WS-SVL
     PERFORM NB-S
     MOVE "count" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE 1 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     MOVE "front" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "minecraft:angler_pottery_sherd" TO WS-SV
     MOVE 30 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{sherds:{back:{id:minecraft:brick,count:1},front:{id:minecraft:angler_pottery_sherd,count:1}}}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: sherd pattern (5.2): the item <key>_pottery_sherd provides the pattern <key> for the 23 keys; any other item (the brick) has none (length 0 and plain side)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:angler_pottery_sherd" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     STRING WS-TX(1:WS-B) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "minecraft:snort_pottery_sherd" TO WS-KEY
     MOVE 29 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     STRING WS-TX(1:WS-B) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "minecraft:flow_pottery_sherd" TO WS-KEY
     MOVE 28 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     STRING WS-TX(1:WS-B) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     MOVE "minecraft:brick" TO WS-KEY
     MOVE 15 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:stick_pottery_sherd" TO WS-KEY
     MOVE 29 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:blade_sherd" TO WS-KEY
     MOVE 21 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:pottery_sherd" TO WS-KEY
     MOVE 23 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "minecraft:angler_pottery_sherx" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE "6 angler 5 snort 4 flow 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: sherd patterns (5.2): all 23 keys map; the sum of the pattern key lengths is checked" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-C
     MOVE "minecraft:angler_pottery_sherd" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:archer_pottery_sherd" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:arms_up_pottery_sherd" TO WS-KEY
     MOVE 31 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:blade_pottery_sherd" TO WS-KEY
     MOVE 29 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:brewer_pottery_sherd" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:burn_pottery_sherd" TO WS-KEY
     MOVE 28 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:danger_pottery_sherd" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:explorer_pottery_sherd" TO WS-KEY
     MOVE 32 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:flow_pottery_sherd" TO WS-KEY
     MOVE 28 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:friend_pottery_sherd" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:guster_pottery_sherd" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:heart_pottery_sherd" TO WS-KEY
     MOVE 29 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:heartbreak_pottery_sherd" TO WS-KEY
     MOVE 34 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:howl_pottery_sherd" TO WS-KEY
     MOVE 28 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:miner_pottery_sherd" TO WS-KEY
     MOVE 29 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:mourner_pottery_sherd" TO WS-KEY
     MOVE 31 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:plenty_pottery_sherd" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:prize_pottery_sherd" TO WS-KEY
     MOVE 29 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:scrape_pottery_sherd" TO WS-KEY
     MOVE 30 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:sheaf_pottery_sherd" TO WS-KEY
     MOVE 29 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:shelter_pottery_sherd" TO WS-KEY
     MOVE 31 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:skull_pottery_sherd" TO WS-KEY
     MOVE 29 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE "minecraft:snort_pottery_sherd" TO WS-KEY
     MOVE 29 TO WS-A
     CALL "BE3-SHERD-PATTERN" USING WS-KEY WS-A WS-TX WS-B
     ADD WS-B TO WS-C
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "134" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: insert (5.3, worked example 8): an empty pot takes one item and the pitch is 0.7 + 0.5 * count / maximum; the same item grows it (2/64 ...); a different item, or a full stack, is refused" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 100 TO WS-A
     MOVE 0 TO WS-B
     MOVE 64 TO WS-C
     CALL "BE3-POT-INSERT" USING WS-IDX WS-A WS-B WS-C WS-E WS-FA WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FA) * 10000
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     CALL "BE3-POT-INSERT" USING WS-IDX WS-A WS-B WS-C WS-E WS-FA WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FA) * 10000
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     CALL "BE3-POT-INSERT" USING WS-IDX WS-A WS-B WS-C WS-E WS-FA WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FA) * 10000
     PERFORM ADD-N
     MOVE WS-F TO WS-SHOW
     PERFORM ADD-N
     MOVE 101 TO WS-A
     CALL "BE3-POT-INSERT" USING WS-IDX WS-A WS-B WS-C WS-E WS-FA WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-ITEM(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE 100 TO WS-A
     MOVE 3 TO BE-SLOT-COUNT(WS-IDX, 1)
     MOVE 3 TO WS-C
     CALL "BE3-POT-INSERT" USING WS-IDX WS-A WS-B WS-C WS-E WS-FA WS-F
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-SLOT-COUNT(WS-IDX, 1) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 1 7078 1 1 2 7156 1 1 3 7234 1 0 3 100 0 3" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: wobble durations (5.4): POSITIVE (data 0) lasts 7 ticks, NEGATIVE (data 1) 10" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     CALL "BE3-POT-DURATION" USING WS-A WS-B
     MOVE 1 TO WS-A
     CALL "BE3-POT-DURATION" USING WS-A WS-C
     MOVE WS-B TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE "7 10" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: loot table and unknown keys (5.1, 5.2): a LootTable hides the item (cleared, a later item ignored); the seed is not written when 0; unknown sherd keys of any tag type are skipped" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "item" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE 2 TO WS-ITEM
     MOVE 3 TO WS-NV
     PERFORM NB-STACK
     PERFORM NB-E
     MOVE "LootTable" TO WS-NM
     MOVE 9 TO WS-NML
     MOVE "lt:b" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "item" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE 2 TO WS-ITEM
     MOVE 3 TO WS-NV
     PERFORM NB-STACK
     PERFORM NB-E
     MOVE "sherds" TO WS-NM
     MOVE 6 TO WS-NML
     PERFORM NB-C
     MOVE "top" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE "x" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     MOVE "left" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE "id" TO WS-NM
     MOVE 2 TO WS-NML
     MOVE "minecraft:howl_pottery_sherd" TO WS-SV
     MOVE 28 TO WS-SVL
     PERFORM NB-S
     MOVE "extra" TO WS-NM
     MOVE 5 TO WS-NML
     MOVE "y" TO WS-SV
     MOVE 1 TO WS-SVL
     PERFORM NB-S
     PERFORM NB-E
     MOVE "top" TO WS-NM
     MOVE 3 TO WS-NML
     MOVE 4 TO WS-NV
     PERFORM NB-I
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{sherds:{left:{id:minecraft:howl_pottery_sherd,count:1}},LootTable:lt:b}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: loot table seed load (5.1): LootTable and LootTableSeed load and save back" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "LootTable" TO WS-NM
     MOVE 9 TO WS-NML
     MOVE "lt:e" TO WS-SV
     MOVE 4 TO WS-SVL
     PERFORM NB-S
     MOVE "LootTableSeed" TO WS-NM
     MOVE 13 TO WS-NML
     MOVE 99 TO WS-LV
     PERFORM NB-LONG
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{LootTable:lt:e,LootTableSeed:99}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: loot table seed (5.1): a non-zero LootTableSeed is saved with the table" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 4 TO BE-LOOT-LENGTH(WS-IDX)
     MOVE "lt:d" TO BE-LOOT(WS-IDX)
     MOVE 77 TO BE-SEED(WS-IDX)
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE "{LootTable:lt:d,LootTableSeed:77}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: block event (5.4): type 1 with data 0 or 1 records the game time and the style; any other type or data goes to the base class (not handled, state kept)" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     MOVE 100 TO WS-C
     CALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     MOVE 200 TO WS-C
     CALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 2 TO WS-B
     MOVE 300 TO WS-C
     CALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE 2 TO WS-A
     MOVE 0 TO WS-B
     MOVE 400 TO WS-C
     CALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE -1 TO WS-B
     MOVE 500 TO WS-C
     CALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 5) TO WS-SHOW
     PERFORM ADD-N
     MOVE BE-XI(WS-IDX, 6) TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 100 0 1 200 1 0 200 1 0 200 1 0 200 1" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: progress (5.5, worked example 9): (gameTime - start + partial) / duration; started at 100 as POSITIVE, time 103, partial 0.5 gives 0.5; a pot that never wobbled gives 0" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     MOVE 100 TO WS-C
     MOVE 0.5 TO WS-FA
     CALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E
     MOVE 1 TO WS-A
     MOVE 100 TO WS-C
     CALL "BE3-POT-EVENT" USING WS-IDX WS-A WS-B WS-C WS-E
     MOVE 103 TO WS-C
     CALL "BE3-POT-PROGRESS" USING WS-IDX WS-C WS-FA WS-FB
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     MOVE 103 TO WS-C
     CALL "BE3-POT-PROGRESS" USING WS-IDX WS-C WS-FA WS-FC
     COMPUTE WS-SHOW ROUNDED = (WS-FB) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FC) * 1000000
     PERFORM ADD-N
     MOVE "500000 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: wobble animation (5.5, worked example 9): POSITIVE rotates about X by (-1.5 * (cos a + 0.5)) * sin(a / 2) * 0.015625 and about Z by sin a * 0.015625 with a = 2 pi * progress; NEGATIVE about" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 0 TO WS-A
     COMPUTE WS-FA = 0.5
     CALL "BE3-POT-POSE" USING WS-A WS-FA WS-FB WS-FC WS-FD
     COMPUTE WS-SHOW ROUNDED = (WS-FB) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FC) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FD) * 1000000
     PERFORM ADD-N
     MOVE 0 TO WS-A
     COMPUTE WS-FA = 0.25
     CALL "BE3-POT-POSE" USING WS-A WS-FA WS-FB WS-FC WS-FD
     COMPUTE WS-SHOW ROUNDED = (WS-FB) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FC) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FD) * 1000000
     PERFORM ADD-N
     MOVE 0 TO WS-A
     COMPUTE WS-FA = 1.0
     CALL "BE3-POT-POSE" USING WS-A WS-FA WS-FB WS-FC WS-FD
     COMPUTE WS-SHOW ROUNDED = (WS-FB) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FC) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FD) * 1000000
     PERFORM ADD-N
     MOVE 0 TO WS-A
     COMPUTE WS-FA = 1.5
     CALL "BE3-POT-POSE" USING WS-A WS-FA WS-FB WS-FC WS-FD
     COMPUTE WS-SHOW ROUNDED = (WS-FB) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FC) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FD) * 1000000
     PERFORM ADD-N
     MOVE 0 TO WS-A
     COMPUTE WS-FA = -0.1
     CALL "BE3-POT-POSE" USING WS-A WS-FA WS-FB WS-FC WS-FD
     COMPUTE WS-SHOW ROUNDED = (WS-FB) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FC) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FD) * 1000000
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 0.5
     CALL "BE3-POT-POSE" USING WS-A WS-FA WS-FB WS-FC WS-FD
     COMPUTE WS-SHOW ROUNDED = (WS-FB) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FC) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FD) * 1000000
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 0.2
     CALL "BE3-POT-POSE" USING WS-A WS-FA WS-FB WS-FC WS-FD
     COMPUTE WS-SHOW ROUNDED = (WS-FB) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FC) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FD) * 1000000
     PERFORM ADD-N
     MOVE 1 TO WS-A
     COMPUTE WS-FA = 0.0
     CALL "BE3-POT-POSE" USING WS-A WS-FA WS-FB WS-FC WS-FD
     COMPUTE WS-SHOW ROUNDED = (WS-FB) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FC) * 1000000
     PERFORM ADD-N
     COMPUTE WS-SHOW ROUNDED = (WS-FD) * 1000000
     PERFORM ADD-N
     MOVE "11719 0 0 -8286 15625 0 0 0 0 0 0 0 0 0 0 0 0 62500 0 0 -95106 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: breaking (5.3): a main-hand item in breaks_decorated_pots without an enchantment of prevents_decorated_pot_shattering sets cracked with flags 260; otherwise the pot stays whole (cracked," TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE 1 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-POT-BREAK" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 1 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-POT-BREAK" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     CALL "BE3-POT-BREAK" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE 0 TO WS-A
     MOVE 1 TO WS-B
     CALL "BE3-POT-BREAK" USING WS-A WS-B WS-C WS-E
     MOVE WS-C TO WS-SHOW
     PERFORM ADD-N
     MOVE WS-E TO WS-SHOW
     PERFORM ADD-N
     MOVE "1 260 0 0 0 0 0 0" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "acceptance US12 31-3§5 Decorated pots: item (5.1): the stored stack loads and saves under item (one slot); with a LootTable pending the item key is not written" TO TL-CASE
     PERFORM BEGIN-CASE
     MOVE "minecraft:decorated_pot" TO WS-KEY
     MOVE 23 TO WS-SVL
     MOVE 41 TO WS-NV
     MOVE 5 TO WS-X
     MOVE 70 TO WS-Y
     MOVE 5 TO WS-Z
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-NV WS-KEY WS-SVL WS-IDX
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE "item" TO WS-NM
     MOVE 4 TO WS-NML
     PERFORM NB-C
     MOVE 2 TO WS-ITEM
     MOVE 3 TO WS-NV
     PERFORM NB-STACK
     PERFORM NB-E
     PERFORM LOAD-BUFFER
     MOVE 2 TO WS-FORM
     PERFORM SAVE-RENDER
     MOVE 4 TO BE-LOOT-LENGTH(WS-IDX)
     MOVE "lt:a" TO BE-LOOT(WS-IDX)
     PERFORM SAVE-RENDER
     MOVE "{item:{id:cobolcraft:greystone,count:3}} {LootTable:lt:a}" TO TL-EXPECTED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     STOP RUN.

 BEGIN-CASE.
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-PTR
     .

 ADD-N.
     STRING FUNCTION TRIM(WS-SHOW) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> Saves entity WS-IDX in form WS-FORM, renders the compound and appends it to TL-OBSERVED.
 SAVE-RENDER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-T10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-PTR
     .

*> The NBT builders of the cases (name WS-NM and length WS-NML, text WS-SV and length WS-SVL, number WS-NV, list type WS-LT and count WS-LC).
 NB-S.
     CALL "NBT-WRITE-STRING" USING PB-BUFFER WS-NM WS-NML WS-SV WS-SVL
     .
 NB-I.
     CALL "NBT-WRITE-INT" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-LONG.
     CALL "NBT-WRITE-LONG" USING PB-BUFFER WS-NM WS-NML WS-LV
     .
 NB-B.
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WS-NM WS-NML WS-NV
     .
 NB-C.
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WS-NM WS-NML
     .
 NB-E.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     .
 NB-STACK.
     MOVE 0 TO WS-KP
     CALL "PNBT-STACK-WRITE" USING PB-BUFFER WS-ITEM WS-NV WS-KP
     .
 NB-L.
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-NM WS-NML WS-LT WS-LC
     .

*> Loads entity WS-IDX from the compound the case built in PB-BUFFER (the closing End tag is written here).
 LOAD-BUFFER.
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "BE-LOAD" USING WS-IDX PB-BUFFER
     CALL "PB-FREE" USING PB-BUFFER
     .
 END PROGRAM TEST-BE-31-3-5.

 COPY CORETEST.
