*> The turtle egg and frogspawn blocks as hooks of the block update machinery (002-lane-mobsa4; docs/protocol/29b-falling-growth-fire-7-aquatic-eggs-honey-cauldron.md sections 3 and 5, 44 part 4 section 11).
*> - EGG-RULES-OPEN (no parameters; called after GB-RULES-OPEN when a world opens): registers for the turtle egg the random-tick marker (kind 11) and the hooks onPlace (kind 1) and random tick
*>   (kind 8), for frogspawn onPlace (1), updateShape (4) and the scheduled tick (7), all with effect 10 (EGG-BLOCK-HOOK); a block that already has its rows is left alone.
*> - EGG-BLOCK-HOOK USING kind, dim, x, y, z, state, a, b, out state (the arguments of BU-HOOK):
*>   turtle egg onPlace: sand below on the server: level event 2012 with data 15. Random tick: the hatch chance of the day time (GC7-EGG-ATTR: 1.0 from tick 21062 to 21904, else 0.002) is compared
*>     with nextFloat (drawn only when the chance is above 0, GC7-EGG-GATE), then with sand below (GC7-EGG-RT): the hatch stage rises (eggs kept) and the sand particles run again; at stage 2 the
*>     block is removed (level event 2001) and one baby turtle per egg appears at x + 0.3 + 0.2 i, z + 0.3 (GC7-EGG-BABY) with age -24000 and the block as its home.
*>   frogspawn onPlace: a block tick after 3600 + nextInt(8400) ticks (GC7-FROG-DELAY). updateShape: no support (a water source below, nothing but water or lava above counts as water or lava)
*>     makes it air. Tick: no support destroys it, else it hatches: removed (level event 2001) and 2 + nextInt(4) tadpoles appear at x + clamp(nextDouble, 0.2, 0.8), y - 0.5, z + clamp(...)
*>     with yaw 1 + nextInt(360) (GC7-FROG-TADPOLES, GC7-FROG-OFFSET).
*>   Gaps: the sand and supports_frogspawn block tags are data not given in the docs (the sand tag is taken as sand and red sand, supports_frogspawn as a water source only), the sounds,
*>   the game events, the baby tadpole's home.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EGG-RULES-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CBLOCKS.
 COPY BUSTATE.
 01 WS-I                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KIND                BINARY-LONG.
 01 WS-EFFECT              BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 PROCEDURE DIVISION.
     CALL "BU-ENSURE"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > CB-BLOCK-COUNT
         MOVE SPACES TO WS-KEY
         CALL "KEY-NAMESPACED" USING CB-KEY(WS-I) WS-KEY
         IF WS-KEY = "minecraft:turtle_egg" OR WS-KEY = "minecraft:frogspawn"
             COMPUTE WS-BLOCK = WS-I - 1
             MOVE 0 TO WS-FOUND
             PERFORM VARYING WS-R FROM 1 BY 1 UNTIL WS-R > BU-RULE-COUNT
                 IF BU-R-KIND(WS-R) = 1 AND BU-R-BLOCK(WS-R) = WS-BLOCK AND BU-R-EFFECT(WS-R) = 10
                     MOVE 1 TO WS-FOUND
                 END-IF
             END-PERFORM
             IF WS-FOUND = 0
                 MOVE 10 TO WS-EFFECT
                 MOVE 1 TO WS-KIND
                 CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
                 IF WS-KEY = "minecraft:turtle_egg"
                     MOVE 11 TO WS-KIND
                     MOVE 0 TO WS-EFFECT
                     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
                     MOVE 8 TO WS-KIND
                     MOVE 10 TO WS-EFFECT
                     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
                 ELSE
                     MOVE 4 TO WS-KIND
                     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
                     MOVE 7 TO WS-KIND
                     CALL "BU-RULE-ADD" USING WS-KIND WS-BLOCK WS-EFFECT WS-ZERO WS-ZERO2
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EGG-RULES-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EGG-IS-SAND.
*> USING dim, x, y, z, sand out: the block in the cell is in the tag sand (stand-in: sand and red sand).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-SAND                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-SAND.
     MOVE 0 TO L-SAND
     CALL "IP-BLOCK-KEY" USING L-DIM L-X L-Y L-Z WS-KEY WS-LENGTH
     IF WS-KEY = "minecraft:sand" OR WS-KEY = "minecraft:red_sand"
         MOVE 1 TO L-SAND
     END-IF
     GOBACK.
 END PROGRAM EGG-IS-SAND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EGG-SPAWN-HOOK-BABIES.
*> USING dim, x, y, z, eggs: one baby turtle per egg.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 01 WS-KEY                 PIC X(112) VALUE "minecraft:turtle".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-XO                  BINARY-LONG.
 01 WS-ZO                  BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-EGGS                 BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-EGGS.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-EGGS
         CALL "GC7-EGG-BABY" USING WS-I WS-XO WS-ZO WS-AGE
         COMPUTE WS-PX = L-X + WS-XO / 1000
         MOVE L-Y TO WS-PY
         COMPUTE WS-PZ = L-Z + WS-ZO / 1000
         CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-ROW
         IF WS-ROW > 0
             MOVE WS-AGE TO EN-MOBAGE(WS-ROW)
             MOVE 1 TO EN-VARIANT(WS-ROW) EN-HOME-SET(WS-ROW)
             MOVE L-X TO EN-HOME-X(WS-ROW)
             MOVE L-Y TO EN-HOME-Y(WS-ROW)
             MOVE L-Z TO EN-HOME-Z(WS-ROW)
             CALL "MOB-DATA-SEND" USING WS-ROW
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EGG-SPAWN-HOOK-BABIES.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EGG-BLOCK-HOOK RECURSIVE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 01 WS-EGGS-D              PIC 9.
 01 WS-HATCH-D             PIC 9.
 01 WS-KEY                 PIC X(48).
 01 WS-BELOW-KEY           PIC X(48).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BELOW               BINARY-LONG.
 01 WS-ABOVE               BINARY-LONG.
 01 WS-SAND                BINARY-LONG.
 01 WS-CHANCE              BINARY-LONG.
 01 WS-DRAW                FLOAT-LONG.
 01 WS-GATE                BINARY-LONG.
 01 WS-DREW                BINARY-LONG.
 01 WS-HATCH               BINARY-LONG.
 01 WS-EGGS                BINARY-LONG.
 01 WS-ACTION              BINARY-LONG.
 01 WS-NEW-HATCH           BINARY-LONG.
 01 WS-BABIES              BINARY-LONG.
 01 WS-AGAIN               BINARY-LONG.
 01 WS-GAME-EVENT          BINARY-LONG.
 01 WS-EVENTS              BINARY-LONG.
 01 WS-DAYTICK             BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-KEY-LONG            PIC X(112) VALUE "turtle_egg".
 01 WS-SUPPORT-BLOCK       BINARY-LONG VALUE 0.
 01 WS-NAME-H              PIC X(24) VALUE "hatch".
 01 WS-NAME-E              PIC X(24) VALUE "eggs".
 01 WS-NAME-L              PIC X(24) VALUE "level".
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-PAIRS               PIC X(160).
 01 WS-NEW-STATE           BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FLAGS-2             BINARY-LONG VALUE 2.
 01 WS-FLAGS-3             BINARY-LONG VALUE 3.
 01 WS-BUDGET              BINARY-LONG VALUE 512.
 01 WS-SET                 BINARY-LONG.
 01 WS-Y-BELOW             BINARY-LONG.
 01 WS-Y-ABOVE             BINARY-LONG.
 01 WS-EVENT-ID            BINARY-LONG.
 01 WS-DATA                BINARY-LONG.
 01 WS-NO-PLAYER           BINARY-LONG VALUE 0.
 01 WS-SERVER-KEY          PIC X(24).
 01 WS-DELAY               BINARY-LONG.
 01 WS-DRAW-D              BINARY-LONG.
 01 WS-BOUND-D             BINARY-LONG VALUE 8400.
 01 WS-TYPE-BLOCK          BINARY-LONG VALUE 1.
 01 WS-PRIORITY            BINARY-LONG VALUE 0.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-SUPPORT             BINARY-LONG.
 01 WS-COUNT-DRAW          BINARY-LONG.
 01 WS-YAW-DRAW            BINARY-LONG.
 01 WS-BOUND-C             BINARY-LONG VALUE 4.
 01 WS-BOUND-Y             BINARY-LONG VALUE 360.
 01 WS-COUNT               BINARY-LONG.
 01 WS-YAWV                BINARY-LONG.
 01 WS-OFFY                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-OFFX                BINARY-LONG.
 01 WS-OFFZ                BINARY-LONG.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-TKEY                PIC X(112) VALUE "minecraft:tadpole".
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-STATE                BINARY-LONG.
 01 L-A                    BINARY-LONG.
 01 L-B                    BINARY-LONG.
 01 L-OUT                  BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-DIM L-X L-Y L-Z L-STATE L-A L-B L-OUT.
     GO TO MAIN-LINE.
 EGG-RANDOM-TICK.
     COMPUTE WS-DAYTICK = FUNCTION MOD(CW-TIME, 24000)
     CALL "GC7-EGG-ATTR" USING WS-DAYTICK WS-CHANCE
     MOVE 0 TO WS-DRAW
     IF WS-CHANCE > 0
         CALL "LEVEL-RANDOM-FLOAT" USING WS-DRAW
     END-IF
     CALL "GC7-EGG-GATE" USING WS-CHANCE WS-DRAW WS-GATE WS-DREW
     CALL "EGG-IS-SAND" USING L-DIM L-X WS-Y-BELOW L-Z WS-SAND
     CALL "BLOCK-STATE-PROP" USING WS-ONE L-STATE WS-NAME-H WS-TEXT WS-RESULT
     COMPUTE WS-HATCH = FUNCTION NUMVAL(WS-TEXT)
     CALL "BLOCK-STATE-PROP" USING WS-ONE L-STATE WS-NAME-E WS-TEXT WS-RESULT
     COMPUTE WS-EGGS = FUNCTION NUMVAL(WS-TEXT)
     CALL "GC7-EGG-RT" USING WS-GATE WS-SAND WS-HATCH WS-EGGS WS-ACTION WS-NEW-HATCH WS-BABIES WS-AGAIN WS-GAME-EVENT WS-EVENTS
     IF WS-ACTION = 1
         MOVE SPACES TO WS-PAIRS
         MOVE WS-EGGS TO WS-EGGS-D
         MOVE WS-NEW-HATCH TO WS-HATCH-D
         STRING "eggs=" WS-EGGS-D ",hatch=" WS-HATCH-D DELIMITED BY SIZE INTO WS-PAIRS
         CALL "BLOCKS-STATE-OF" USING WS-KEY-LONG WS-PAIRS WS-NEW-STATE
*>       The write runs onPlace again (GC7-EGG-RT "again"): the sand particles of the first case.
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-NEW-STATE WS-FLAGS-2 WS-BUDGET WS-SET
     END-IF
     IF WS-ACTION = 2
         CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-AIR WS-FLAGS-3 WS-BUDGET WS-SET
         MOVE 2001 TO WS-EVENT-ID
         MOVE L-STATE TO WS-DATA
         CALL "LEVEL-EVENT" USING L-DIM WS-EVENT-ID L-X L-Y L-Z WS-DATA WS-NO-PLAYER
         CALL "EGG-SPAWN-HOOK-BABIES" USING L-DIM L-X L-Y L-Z WS-BABIES
     END-IF.

 FROG-SURVIVES.
     MOVE 0 TO WS-SUPPORT
     CALL "IP-BLOCK-KEY" USING L-DIM L-X WS-Y-BELOW L-Z WS-BELOW-KEY WS-LENGTH
     MOVE 0 TO WS-BELOW
     IF WS-BELOW-KEY = "minecraft:water"
         CALL "WORLD-GET-BLOCK" USING L-DIM L-X WS-Y-BELOW L-Z WS-NEW-STATE
         CALL "BLOCK-STATE-PROP" USING WS-ONE WS-NEW-STATE WS-NAME-L WS-TEXT WS-RESULT
         IF WS-RESULT = 1 AND WS-TEXT(1:1) = "0"
             MOVE 1 TO WS-BELOW
         END-IF
     END-IF
     CALL "IP-BLOCK-KEY" USING L-DIM L-X WS-Y-ABOVE L-Z WS-BELOW-KEY WS-LENGTH
     MOVE 1 TO WS-ABOVE
     IF WS-BELOW-KEY = "minecraft:water" OR WS-BELOW-KEY = "minecraft:lava"
         MOVE 0 TO WS-ABOVE
     END-IF
     CALL "GC7-FROG-SURVIVE" USING WS-BELOW WS-SUPPORT-BLOCK WS-ABOVE WS-SUPPORT.

 FROG-TICK.
     PERFORM FROG-SURVIVES
     CALL "LEVEL-SET-BLOCK" USING L-DIM L-X L-Y L-Z WS-AIR WS-FLAGS-3 WS-BUDGET WS-SET
     IF WS-SUPPORT = 1
         MOVE 2001 TO WS-EVENT-ID
         MOVE L-STATE TO WS-DATA
         CALL "LEVEL-EVENT" USING L-DIM WS-EVENT-ID L-X L-Y L-Z WS-DATA WS-NO-PLAYER
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-TKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "LEVEL-RANDOM-INT" USING WS-BOUND-C WS-COUNT-DRAW
         CALL "LEVEL-RANDOM-INT" USING WS-BOUND-Y WS-YAW-DRAW
         CALL "GC7-FROG-TADPOLES" USING WS-COUNT-DRAW WS-YAW-DRAW WS-COUNT WS-YAWV WS-OFFY
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
             CALL "LEVEL-RANDOM-DOUBLE-OFFSET" USING WS-OFFX
             CALL "LEVEL-RANDOM-DOUBLE-OFFSET" USING WS-OFFZ
             COMPUTE WS-PX = L-X + WS-OFFX / 1000000000
             COMPUTE WS-PY = L-Y + WS-OFFY / 1000
             COMPUTE WS-PZ = L-Z + WS-OFFZ / 1000000000
             MOVE WS-YAWV TO WS-YAW
             CALL "MOB-SPAWN" USING L-DIM WS-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-ROW
         END-PERFORM
     END-IF.
 MAIN-LINE.
     CALL "IP-BLOCK-KEY" USING L-DIM L-X L-Y L-Z WS-KEY WS-LENGTH
     COMPUTE WS-Y-BELOW = L-Y - 1
     COMPUTE WS-Y-ABOVE = L-Y + 1
     IF WS-KEY = "minecraft:turtle_egg"
         EVALUATE L-KIND
             WHEN 1
                 CALL "EGG-IS-SAND" USING L-DIM L-X WS-Y-BELOW L-Z WS-SAND
                 IF WS-SAND = 1
                     MOVE 2012 TO WS-EVENT-ID
                     MOVE 15 TO WS-DATA
                     CALL "LEVEL-EVENT" USING L-DIM WS-EVENT-ID L-X L-Y L-Z WS-DATA WS-NO-PLAYER
                 END-IF
             WHEN 8
                 PERFORM EGG-RANDOM-TICK
         END-EVALUATE
     END-IF
     IF WS-KEY = "minecraft:frogspawn"
         EVALUATE L-KIND
             WHEN 1
                 CALL "LEVEL-RANDOM-INT" USING WS-BOUND-D WS-DRAW-D
                 CALL "GC7-FROG-DELAY" USING WS-DRAW-D WS-DELAY
                 MOVE CB-S-BLOCK(L-STATE + 1) TO WS-BLOCK
                 CALL "BT-SCHEDULE" USING L-DIM WS-TYPE-BLOCK WS-BLOCK L-X L-Y L-Z WS-DELAY WS-PRIORITY WS-RESULT
             WHEN 4
                 PERFORM FROG-SURVIVES
                 IF WS-SUPPORT = 0
                     MOVE 0 TO L-OUT
                 END-IF
             WHEN 7
                 PERFORM FROG-TICK
         END-EVALUATE
     END-IF
     CONTINUE.
 END PROGRAM EGG-BLOCK-HOOK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LEVEL-RANDOM-DOUBLE-OFFSET.
*> USING offset x 1e9 out: nextDouble of the level random (next(26) x 2^27 + next(27), over 2^53), clamped by GC7-FROG-OFFSET to 0.2 to 0.8.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BITS-A              BINARY-LONG VALUE 26.
 01 WS-BITS-B              BINARY-LONG VALUE 27.
 01 WS-A                   BINARY-DOUBLE.
 01 WS-B                   BINARY-DOUBLE.
 01 WS-DRAW                FLOAT-LONG.
 LINKAGE SECTION.
 01 L-OFFSET               BINARY-LONG.
 PROCEDURE DIVISION USING L-OFFSET.
     CALL "LEVEL-RANDOM-NEXT" USING WS-BITS-A WS-A
     CALL "LEVEL-RANDOM-NEXT" USING WS-BITS-B WS-B
     COMPUTE WS-DRAW = (WS-A * 134217728 + WS-B) / 9007199254740992
     CALL "GC7-FROG-OFFSET" USING WS-DRAW L-OFFSET
     GOBACK.
 END PROGRAM LEVEL-RANDOM-DOUBLE-OFFSET.
