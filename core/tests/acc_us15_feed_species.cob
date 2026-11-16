*> Acceptance test (US15; docs/protocol/18-mob-framework.md section 8.1, 19 sections 2 and 3.4): in a standard world a survival player right-clicks (Interact 0x1A, main hand)
*> each breedable species with its own food. Each one uses one item, falls in love for 600 ticks (Entity Event 18, the hearts, reaches the viewer), and two animals in love
*> breed after 60 ticks together: one baby of the species and an experience orb. Operator report: sheep did not take wheat (before the mobs lane was merged).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-FEED-SPECIES.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY CITEMS.
 COPY PROTO.
 COPY BRWORLD.
 COPY XORO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-ITEM-ROW            PIC X(270).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-XLO                BINARY-LONG.
 01 WS-XHI                BINARY-LONG.
 01 WS-ZLO                BINARY-LONG.
 01 WS-ZHI                BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-EDIT                PIC -(9)9.
 01 WS-NEEDLE              PIC X(40).
 01 WS-HITS                BINARY-LONG.
 01 WS-COW-TYPE            BINARY-LONG.
 01 WS-WANT-KEY            PIC X(112).
 01 WS-WANT-TYPE           BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-GIVE-COUNT          BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-ROW-A               BINARY-LONG.
 01 WS-ROW-B               BINARY-LONG.
 01 WS-ROW-C               BINARY-LONG.
 01 WS-BABY                BINARY-LONG.
 01 WS-BABIES              BINARY-LONG.
 01 WS-ORBS                BINARY-LONG.
 01 WS-ORB-TYPE            BINARY-LONG.
 01 WS-COUNT-ITEM          BINARY-LONG.
 01 WS-COUNT-TOTAL         BINARY-LONG.
 01 WS-ID-A                BINARY-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-CASE                PIC X(240).
 01 WS-EXPECT              BINARY-DOUBLE.
 01 WS-OBSERVE             BINARY-DOUBLE.
 01 WS-SLOT-ITEM           BINARY-LONG.
 01 WS-WHEAT               BINARY-LONG.
 01 WS-HX                  FLOAT-LONG.
 01 WS-HZ                  FLOAT-LONG.
 01 WS-WALK                BINARY-LONG.
 01 WS-DRAW                BINARY-LONG.
 01 WS-COLOR               BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-TABLE.
    05 FILLER PIC X(48) VALUE "sheep                   wheat                   ".
    05 FILLER PIC X(48) VALUE "cow                     wheat                   ".
    05 FILLER PIC X(48) VALUE "mooshroom               wheat                   ".
    05 FILLER PIC X(48) VALUE "pig                     carrot                  ".
    05 FILLER PIC X(48) VALUE "chicken                 wheat_seeds             ".
    05 FILLER PIC X(48) VALUE "goat                    wheat                   ".
    05 FILLER PIC X(48) VALUE "rabbit                  carrot                  ".
    05 FILLER PIC X(48) VALUE "fox                     sweet_berries           ".
    05 FILLER PIC X(48) VALUE "panda                   bamboo                  ".
    05 FILLER PIC X(48) VALUE "llama                   hay_block               ".
    05 FILLER PIC X(48) VALUE "camel                   cactus                  ".
    05 FILLER PIC X(48) VALUE "horse                   golden_carrot           ".
 01 WS-ROWS REDEFINES WS-TABLE.
    05 WS-SP                OCCURS 12 TIMES.
       10 WS-SP-KEY         PIC X(24).
       10 WS-SP-FOOD        PIC X(24).
 01 WS-S                   BINARY-LONG.
 01 WS-BABY-OK             BINARY-LONG.
 01 WS-LABEL               PIC X(24).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 0 TO PL-HELD(WS-PLAYER)
     MOVE 6000 TO CW-TIME
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:stone" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     COMPUTE WS-CX = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-CZ = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-FLOOR = FUNCTION INTEGER(PL-Y(WS-PLAYER)) + 40
     COMPUTE WS-XLO = WS-CX - 4
     COMPUTE WS-XHI = WS-CX + 4
     COMPUTE WS-ZLO = WS-CZ - 4
     COMPUTE WS-ZHI = WS-CZ + 4
     PERFORM VARYING WS-X FROM WS-XLO BY 1 UNTIL WS-X > WS-XHI
         PERFORM VARYING WS-Z FROM WS-ZLO BY 1 UNTIL WS-Z > WS-ZHI
             CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-FLOOR WS-Z WS-STATE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 3
                 COMPUTE WS-E = WS-FLOOR + WS-I
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-X WS-E WS-Z WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE PL-X(WS-PLAYER) = WS-CX + 0.5
     COMPUTE PL-Y(WS-PLAYER) = WS-FLOOR + 1
     COMPUTE PL-Z(WS-PLAYER) = WS-CZ + 0.5
     MOVE "minecraft:experience_orb" TO WS-WANT-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-WANT-KEY WS-ORB-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT

     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 12
         PERFORM CLEAR-MOBS
         MOVE WS-SP-KEY(WS-S) TO WS-LABEL
         MOVE WS-SP-KEY(WS-S) TO WS-WANT-KEY
         MOVE 2 TO WS-DX
         MOVE 0 TO WS-DZ
         PERFORM SPAWN-MOB
         MOVE WS-E TO WS-ROW-A
         MOVE 3 TO WS-DX
         PERFORM SPAWN-MOB
         MOVE WS-E TO WS-ROW-B
         IF WS-S >= 10
             MOVE 1 TO EN-TAMED(WS-ROW-A) EN-TAMED(WS-ROW-B)
         END-IF
         MOVE WS-SP-FOOD(WS-S) TO WS-ITEM-KEY
         MOVE 2 TO WS-GIVE-COUNT
         PERFORM GIVE-HELD
         CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
         MOVE EN-ID(WS-ROW-A) TO WS-ID-A
         CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
         CALL "TEST-DRAIN-HUNGER" USING WS-CONN WS-TEXT
         MOVE SPACES TO WS-NEEDLE
         MOVE EN-ID(WS-ROW-A) TO WS-EDIT
         STRING "event " FUNCTION TRIM(WS-EDIT) " 18" DELIMITED BY SIZE INTO WS-NEEDLE
         MOVE 0 TO WS-HITS
         INSPECT WS-TEXT TALLYING WS-HITS FOR ALL FUNCTION TRIM(WS-NEEDLE)
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 18§8.1 Feeding: " FUNCTION TRIM(WS-LABEL) " takes one " FUNCTION TRIM(WS-ITEM-KEY)
             " (uses one item, 600 ticks of love, hearts event)" DELIMITED BY SIZE INTO WS-CASE
         MOVE 1600118 TO WS-EXPECT
         COMPUTE WS-OBSERVE = PL-SLOT-COUNT(WS-PLAYER, 1) * 1000000 + EN-LOVE(WS-ROW-A) * 1000 + WS-HITS * 100 + 18
         PERFORM CHECK-N
         MOVE EN-ID(WS-ROW-B) TO WS-ID-A
         CALL "TEST-INTERACT" USING WS-CONN WS-ID-A WS-HAND0 WS-SNEAK0
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 18§8.1 Feeding: " FUNCTION TRIM(WS-LABEL) " the second one is fed too"
             DELIMITED BY SIZE INTO WS-CASE
         MOVE 600 TO WS-EXPECT
         MOVE EN-LOVE(WS-ROW-B) TO WS-OBSERVE
         PERFORM CHECK-N
         MOVE 0 TO WS-BABIES
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400 OR WS-BABIES > 0
             ADD 1 TO CW-TIME
             CALL "MOB-STEP" USING WS-ROW-A
             CALL "MOB-STEP" USING WS-ROW-B
             PERFORM COUNT-BABIES
         END-PERFORM
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 18§8.1 Feeding: " FUNCTION TRIM(WS-LABEL) " two animals in love breed: one baby of the species"
             DELIMITED BY SIZE INTO WS-CASE
         COMPUTE WS-EXPECT = 1 * 100000 + EN-TYPE(WS-ROW-A)
         MOVE 0 TO WS-OBSERVE
         IF WS-BABIES > 0
             COMPUTE WS-OBSERVE = WS-BABIES * 100000 + EN-TYPE(WS-BABY)
         END-IF
         PERFORM CHECK-N
         PERFORM COUNT-ORBS
         MOVE SPACES TO WS-CASE
         STRING "acceptance US15 18§8.1 Feeding: " FUNCTION TRIM(WS-LABEL) " an experience orb appears"
             DELIMITED BY SIZE INTO WS-CASE
         MOVE 1 TO WS-EXPECT
         MOVE 0 TO WS-OBSERVE
         IF WS-ORBS >= 1
             MOVE 1 TO WS-OBSERVE
         END-IF
         PERFORM CHECK-N
     END-PERFORM
     STOP RUN.

 CLEAR-MOBS.
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0
             CALL "ENTITY-REMOVE" USING WS-N
         END-IF
     END-PERFORM.

 SPAWN-MOB.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = WS-CX + 0.5 + WS-DX
     COMPUTE WS-FY = WS-FLOOR + 1
     COMPUTE WS-FZ = WS-CZ + 0.5 + WS-DZ
     CALL "MOB-SPAWN" USING WS-DIM WS-WANT-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-E.

 FIND-TYPE.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-WANT-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-WANT-TYPE WS-ENTITY-ROW WS-STATUS.

 GIVE-HELD.
     MOVE SPACES TO WS-KEY
     STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-ITEM-KEY) DELIMITED BY SIZE INTO WS-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-KEY WS-ITEM-ID WS-ITEM-ROW WS-STATUS
     MOVE WS-ITEM-ID TO PL-SLOT-ITEM(WS-PLAYER, 1)
     MOVE WS-GIVE-COUNT TO PL-SLOT-COUNT(WS-PLAYER, 1)
     MOVE 0 TO PL-SLOT-VAR(WS-PLAYER, 1).

 COUNT-BABIES.
     MOVE 0 TO WS-BABIES
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-PLAYER(WS-N) = 0 AND EN-MOBAGE(WS-N) < 0 AND EN-VARIANT(WS-N) = 1
             ADD 1 TO WS-BABIES
             MOVE WS-N TO WS-BABY
         END-IF
     END-PERFORM.

 COUNT-ORBS.
     MOVE 0 TO WS-ORBS
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > EN-COUNT
         IF EN-USED(WS-N) = 1 AND EN-TYPE(WS-N) = WS-ORB-TYPE
             ADD 1 TO WS-ORBS
         END-IF
     END-PERFORM.

 CHECK-N.
     MOVE "N" TO TL-MODE
     MOVE WS-CASE TO TL-CASE
     MOVE WS-EXPECT TO TL-EXPECTED-N
     MOVE WS-OBSERVE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-US15-FEED-SPECIES.
 COPY CORETEST.
