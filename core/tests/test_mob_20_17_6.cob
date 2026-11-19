*> Acceptance test (lane p49x; docs/protocol/31 section 6.6, 44-5 section 8, 20 section 17): the hurt callback of a heart-bound creaking and its restriction to 32 blocks. A hit on a bound creaking is
*> redirected through the heart (creakingHurt): 20 trail particles, while the heart is awake 2 or 3 resin spreads (one face each, sound resin_place), the emitter 100 with two bursts a tick for 50 ticks
*> then one, a sound at every multiple of 10; ignored while the emitter runs. The resin rules: an air neighbour of a log gets a clump with the face looking back at the log, a water source a waterlogged
*> clump, a clump lacking the face gets it, anything else (a clump that has it, stone) is skipped and nothing happens. A bound creaking's walk to a cell farther than 32 blocks (squared 1024) from its
*> home is cancelled; damage that bypasses invulnerability (the command kill) still kills it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-20-17-6.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY CBLOCKS.
 COPY CREAKSTATE.
 COPY HEARTSTATE.
 COPY BRWORLD.
 COPY RULES.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CONN                BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-LABEL               PIC X(240).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FSIZE               BINARY-LONG VALUE 70.
 01 WS-FKIND               BINARY-LONG VALUE 1.
 01 WS-HX                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-NX                  BINARY-LONG.
 01 WS-NY                  BINARY-LONG.
 01 WS-NZ                  BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CSLOT               BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-CROW                BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-HEART-AWAKE         BINARY-LONG.
 01 WS-HEART-DORMANT       BINARY-LONG.
 01 WS-HEART-USE           BINARY-LONG.
 01 WS-LOG-Y               BINARY-LONG.
 01 WS-WATER               BINARY-LONG.
 01 WS-STONE               BINARY-LONG.
 01 WS-CLUMP-DEFAULT       BINARY-LONG.
 01 WS-RESIN-BLOCK         BINARY-LONG.
 01 WS-LOG-BLOCK           BINARY-LONG.
 01 WS-NAME                PIC X(24).
 01 WS-TEXT                PIC X(32).
 01 WS-RESULT              BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-OPP                 BINARY-LONG.
 01 WS-FACES               BINARY-LONG.
 01 WS-ON-LOG              BINARY-LONG.
 01 WS-WLOGGED             BINARY-LONG.
 01 WS-FACES-BEFORE        BINARY-LONG.
 01 WS-HEALTH0             BINARY-LONG.
 01 WS-DAMAGE              BINARY-LONG.
 01 WS-TOT-TRAILS          BINARY-LONG.
 01 WS-TOT-NORMAL          BINARY-LONG.
 01 WS-TOT-REVERSE         BINARY-LONG.
 01 WS-TOT-SOUNDS          BINARY-LONG.
 01 WS-SURROUND            BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-FACE-NAME-DATA.
    05 FILLER              PIC X(6) VALUE "down".
    05 FILLER              PIC X(6) VALUE "up".
    05 FILLER              PIC X(6) VALUE "north".
    05 FILLER              PIC X(6) VALUE "south".
    05 FILLER              PIC X(6) VALUE "west".
    05 FILLER              PIC X(6) VALUE "east".
 01 WS-FACE-TABLE REDEFINES WS-FACE-NAME-DATA.
    05 WS-FACE-NAME        PIC X(6) OCCURS 6 TIMES.
 01 WS-STEPS.
    05 WS-STEP             OCCURS 6 TIMES.
       10 WS-DX            BINARY-LONG.
       10 WS-DY            BINARY-LONG.
       10 WS-DZ            BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-CAUSE               BINARY-LONG.
 01 WS-SCAN.
    05 SC-TRAILS           BINARY-LONG.
    05 SC-NORMAL-OK        BINARY-LONG.
    05 SC-REVERSE-OK       BINARY-LONG.
    05 SC-OTHER            BINARY-LONG.
    05 SC-SOUNDS           BINARY-LONG.
    05 SC-CX               FLOAT-LONG.
    05 SC-CY               FLOAT-LONG.
    05 SC-CZ               FLOAT-LONG.
    05 SC-HX               BINARY-LONG.
    05 SC-HY               BINARY-LONG.
    05 SC-HZ               BINARY-LONG.
 01 WS-WALK-X              FLOAT-LONG.
 01 WS-WALK-Z              FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PX                  FLOAT-LONG.
 01 WS-PY                  FLOAT-LONG.
 01 WS-PZ                  FLOAT-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-CONN(WS-PLAYER) TO WS-CONN
     MOVE "N" TO TL-MODE
     MOVE "minecraft:creaking" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 35
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 35
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-PLAYER)) - 1
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-FX WS-FZ WS-FSIZE WS-FY WS-FKIND
     COMPUTE WS-HX = FUNCTION INTEGER(PL-X(WS-PLAYER)) + 4
     COMPUTE WS-HY = WS-FY + 2
     COMPUTE WS-HZ = FUNCTION INTEGER(PL-Z(WS-PLAYER)) + 4
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE 2 TO BW-DIFFICULTY
     MOVE 14000 TO CW-TIME
     PERFORM MAKE-STATES
*>   1. The hurt of an awake heart in air: the faces are new clumps; the particles and sounds of the hit, then the emitter.
     MOVE WS-HEART-AWAKE TO WS-HEART-USE
     MOVE 0 TO WS-SURROUND
     PERFORM SETUP-SCENE
     PERFORM BIND-PROTECTOR
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE EN-HEALTH(WS-CROW) TO WS-HEALTH0
     PERFORM HIT-CREAKING
     MOVE "a hit on a heart-bound creaking does not hurt it" TO WS-LABEL
     MOVE WS-HEALTH0 TO TL-EXPECTED-N
     MOVE EN-HEALTH(WS-CROW) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and starts the emitter at 100" TO WS-LABEL
     MOVE 100 TO TL-EXPECTED-N
     MOVE HT-EMITTER(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     PERFORM COUNT-FACES
     MOVE "an awake heart spreads resin 2 or 3 times: one face each" TO WS-LABEL
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FACES = 2 OR WS-FACES = 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     MOVE "every face looks back at a pale oak log" TO WS-LABEL
     MOVE WS-FACES TO TL-EXPECTED-N
     MOVE WS-ON-LOG TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE WS-FACES TO WS-FACES-BEFORE
     PERFORM SCAN-PACKETS
     MOVE "20 trail particles leave the creaking for the heart (colour 6250335)" TO WS-LABEL
     MOVE 20 TO TL-EXPECTED-N
     MOVE SC-NORMAL-OK TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and no other trail particle" TO WS-LABEL
     MOVE 20 TO TL-EXPECTED-N
     MOVE SC-TRAILS TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "one resin_place sound for each resin spread" TO WS-LABEL
     MOVE WS-FACES TO TL-EXPECTED-N
     MOVE SC-SOUNDS TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   A second hit while the emitter runs is ignored.
     PERFORM HIT-CREAKING
     PERFORM COUNT-FACES
     MOVE "a second hit during the emitter adds no resin" TO WS-LABEL
     MOVE WS-FACES-BEFORE TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     PERFORM SCAN-PACKETS
     MOVE "and no particle or sound" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = SC-TRAILS + SC-SOUNDS
     PERFORM ASSERT-LINE
*>   The emitter: 100 ticks, two bursts a tick while it is above 50 (one leaving the heart: colour 16545810), one after, a sound at every multiple of 10.
     MOVE 0 TO WS-TOT-TRAILS WS-TOT-NORMAL WS-TOT-REVERSE WS-TOT-SOUNDS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 100
         CALL "BE-TICK-ALL"
         PERFORM SCAN-PACKETS
         ADD SC-TRAILS TO WS-TOT-TRAILS
         ADD SC-NORMAL-OK TO WS-TOT-NORMAL
         ADD SC-REVERSE-OK TO WS-TOT-REVERSE
         ADD SC-SOUNDS TO WS-TOT-SOUNDS
     END-PERFORM
     MOVE "100 ticks of the emitter send 150 trail particles" TO WS-LABEL
     MOVE 150 TO TL-EXPECTED-N
     MOVE WS-TOT-TRAILS TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "50 of them leave the heart for the creaking" TO WS-LABEL
     MOVE 50 TO TL-EXPECTED-N
     MOVE WS-TOT-REVERSE TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and 100 leave the creaking for the heart" TO WS-LABEL
     MOVE 100 TO TL-EXPECTED-N
     MOVE WS-TOT-NORMAL TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "a hurt sound every 10 ticks: 10 sounds" TO WS-LABEL
     MOVE 10 TO TL-EXPECTED-N
     MOVE WS-TOT-SOUNDS TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "the emitter has run out" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE HT-EMITTER(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   A dormant heart: the particles and the emitter, but no resin and no sound at the hit.
     MOVE WS-HEART-DORMANT TO WS-HEART-USE
     PERFORM SETUP-SCENE
     PERFORM BIND-PROTECTOR
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM HIT-CREAKING
     PERFORM COUNT-FACES
     MOVE "a dormant heart spreads no resin" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     PERFORM SCAN-PACKETS
     MOVE "but sends the 20 particles" TO WS-LABEL
     MOVE 20 TO TL-EXPECTED-N
     MOVE SC-TRAILS TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and runs the emitter" TO WS-LABEL
     MOVE 100 TO TL-EXPECTED-N
     MOVE HT-EMITTER(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   2. The resin rules. Every neighbour of the two logs is set to one kind of state, the heart is hurt, the faces are counted.
     MOVE WS-HEART-AWAKE TO WS-HEART-USE
     MOVE 2 TO WS-SURROUND
     PERFORM SETUP-SCENE
     PERFORM BIND-PROTECTOR
     PERFORM HIT-CREAKING
     PERFORM COUNT-FACES
     MOVE "water source neighbours: the spread makes waterlogged clumps (2 or 3 faces)" TO WS-LABEL
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF (WS-FACES = 2 OR WS-FACES = 3) AND WS-WLOGGED = WS-FACES
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     MOVE 3 TO WS-SURROUND
     PERFORM SETUP-SCENE
     PERFORM BIND-PROTECTOR
     PERFORM COUNT-FACES
     MOVE WS-FACES TO WS-FACES-BEFORE
     PERFORM HIT-CREAKING
     PERFORM COUNT-FACES
     MOVE "clumps lacking the face: it is added (2 or 3 faces more)" TO WS-LABEL
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FACES = WS-FACES-BEFORE + 2 OR WS-FACES = WS-FACES-BEFORE + 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     MOVE 4 TO WS-SURROUND
     PERFORM SETUP-SCENE
     PERFORM BIND-PROTECTOR
     PERFORM COUNT-FACES
     MOVE WS-FACES TO WS-FACES-BEFORE
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM HIT-CREAKING
     PERFORM COUNT-FACES
     MOVE "clumps that have the face already: nothing is added" TO WS-LABEL
     MOVE WS-FACES-BEFORE TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     PERFORM SCAN-PACKETS
     MOVE "and no resin sound plays" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE SC-SOUNDS TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE 5 TO WS-SURROUND
     PERFORM SETUP-SCENE
     PERFORM BIND-PROTECTOR
     PERFORM HIT-CREAKING
     PERFORM COUNT-FACES
     MOVE "stone neighbours are skipped: no resin" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-FACES TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   The protector is gone: the emitter goes on without particles.
     PERFORM SETUP-SCENE
     PERFORM BIND-PROTECTOR
     PERFORM HIT-CREAKING
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     CALL "ENTITY-REMOVE" USING WS-CROW
     CALL "BE-TICK-ALL"
     MOVE EN-X(WS-CROW) TO SC-CX
     PERFORM SCAN-PACKETS
     MOVE "without a protector the emitter sends no particle" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     MOVE SC-TRAILS TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
     MOVE "and still counts down" TO WS-LABEL
     MOVE 99 TO TL-EXPECTED-N
     MOVE HT-EMITTER(WS-SLOT) TO TL-OBSERVED-N
     PERFORM ASSERT-LINE
*>   A creaking bound to a position where no heart is recorded is hit: nothing happens to it and nothing is sent.
     PERFORM SETUP-SCENE
     COMPUTE WS-PX = WS-HX + 4.5
     COMPUTE WS-PY = WS-HY
     COMPUTE WS-PZ = WS-HZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-CROW
     CALL "CREAKING-BIND" USING WS-CROW WS-HX WS-HY WS-HZ
     MOVE EN-HEALTH(WS-CROW) TO WS-HEALTH0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     PERFORM HIT-CREAKING
     PERFORM SCAN-PACKETS
     MOVE "a hit on a creaking whose heart has no record does nothing" TO WS-LABEL
     MOVE WS-HEALTH0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-HEALTH(WS-CROW) + SC-TRAILS + SC-SOUNDS
     PERFORM ASSERT-LINE
*>   Damage that bypasses invulnerability still kills a bound creaking (the command kill) and a hit on a creaking with no home is an ordinary hit.
     MOVE 0 TO WS-SURROUND
     PERFORM SETUP-SCENE
     PERFORM BIND-PROTECTOR
     MOVE EN-HEALTH(WS-CROW) TO WS-DAMAGE
     MOVE CAUSE-COMMAND TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-CROW WS-DAMAGE WS-CAUSE WS-ZERO
     MOVE "the command kill is not redirected: the creaking dies" TO WS-LABEL
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-USED(WS-CROW) = 0 OR EN-HEALTH(WS-CROW) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
     PERFORM SETUP-SCENE
     MOVE PL-X(WS-PLAYER) TO WS-PX
     MOVE PL-Y(WS-PLAYER) TO WS-PY
     COMPUTE WS-PX = WS-PX + 2
     MOVE PL-Z(WS-PLAYER) TO WS-PZ
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-CROW
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE EN-HEALTH(WS-CROW) TO WS-DAMAGE
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-CROW WS-DAMAGE WS-CAUSE WS-PLAYER
     MOVE "a creaking with no heart takes an ordinary hit and dies" TO WS-LABEL
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-USED(WS-CROW) = 0 OR EN-HEALTH(WS-CROW) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM ASSERT-LINE
*>   3. The path restriction: a step that would end farther than 32 blocks (squared distance of the cells above 1024) from the home is cancelled; inside, and for a creaking without a home, it stands.
     PERFORM SETUP-SCENE
     PERFORM BIND-PROTECTOR
     COMPUTE EN-X(WS-CROW) = WS-HX + 31.5
     COMPUTE EN-Z(WS-CROW) = WS-HZ + 0.5
     MOVE WS-HY TO EN-Y(WS-CROW)
     MOVE 0.9 TO WS-WALK-X
     MOVE 0 TO WS-WALK-Z
     CALL "CREAKING-LEASH" USING WS-CROW WS-WALK-X WS-WALK-Z
     MOVE "a walk from 31 to 32 blocks east of the home (cell 32: 1024) goes on" TO WS-LABEL
     MOVE 900 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-WALK-X * 1000
     PERFORM ASSERT-LINE
     COMPUTE EN-X(WS-CROW) = WS-HX + 32.5
     MOVE 0.6 TO WS-WALK-X
     CALL "CREAKING-LEASH" USING WS-CROW WS-WALK-X WS-WALK-Z
     MOVE "a walk from 32 to 33 blocks (cell 33: 1089) is cancelled" TO WS-LABEL
     MOVE 800 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-WALK-X * 1000 + 800
     PERFORM ASSERT-LINE
     COMPUTE EN-X(WS-CROW) = WS-HX + 20.5
     MOVE 0.2 TO WS-WALK-X
     MOVE 0.1 TO WS-WALK-Z
     CALL "CREAKING-LEASH" USING WS-CROW WS-WALK-X WS-WALK-Z
     MOVE "a walk well inside is untouched" TO WS-LABEL
     MOVE 300 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-WALK-X * 1000 + WS-WALK-Z * 1000
     PERFORM ASSERT-LINE
     COMPUTE EN-X(WS-CROW) = WS-HX + 40.5
     MOVE -1.0 TO WS-WALK-X
     MOVE 0 TO WS-WALK-Z
     CALL "CREAKING-LEASH" USING WS-CROW WS-WALK-X WS-WALK-Z
     MOVE "a creaking already outside may walk toward the home" TO WS-LABEL
     MOVE -1000 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-WALK-X * 1000
     PERFORM ASSERT-LINE
     COMPUTE EN-Y(WS-CROW) = WS-HY + 40
     COMPUTE EN-X(WS-CROW) = WS-HX + 0.5
     MOVE 0.9 TO WS-WALK-X
     CALL "CREAKING-LEASH" USING WS-CROW WS-WALK-X WS-WALK-Z
     MOVE "the distance counts the height too: 40 above the home is outside, the step is cancelled" TO WS-LABEL
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-WALK-X * 1000
     PERFORM ASSERT-LINE
     COMPUTE EN-X(WS-CROW) = WS-HX + 60.5
     MOVE 0.2 TO WS-WALK-X
     MOVE WS-HY TO EN-Y(WS-CROW)
     CALL "CRK-FIND" USING EN-ID(WS-CROW) WS-ZERO WS-CSLOT
     MOVE 0 TO CRK-HOME(WS-CSLOT)
     CALL "CREAKING-LEASH" USING WS-CROW WS-WALK-X WS-WALK-Z
     MOVE "a creaking without a home walks anywhere" TO WS-LABEL
     MOVE 200 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-WALK-X * 1000
     PERFORM ASSERT-LINE
     STOP RUN.

 MAKE-STATES.
     MOVE "minecraft:creaking_heart" TO WS-KEY
     MOVE "axis=y,creaking_heart_state=awake,natural=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-HEART-AWAKE
     MOVE "axis=y,creaking_heart_state=dormant,natural=false" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-HEART-DORMANT
     MOVE "minecraft:pale_oak_log" TO WS-KEY
     MOVE "axis=y" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-LOG-Y
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-LOG-BLOCK
     MOVE "minecraft:water" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WATER
     MOVE "minecraft:stone" TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-STONE
     MOVE "minecraft:resin_clump" TO WS-KEY
     CALL "BLOCKS-ID-OF" USING WS-KEY WS-RESIN-BLOCK
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-CLUMP-DEFAULT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
         COMPUTE WS-DIR = WS-I - 1
         CALL "BU-DIRECTION" USING WS-DIR WS-DX(WS-I) WS-DY(WS-I) WS-DZ(WS-I)
     END-PERFORM
     .

*> A clean scene: no creaking, no heart records, the cells around the heart air, the column (log, WS-HEART-USE, log) and the ten neighbours of the logs set by WS-SURROUND
*> (0 air, 2 water source, 3 clumps with every face but the one looking at the log, 4 clumps with every face, 5 stone).
 SETUP-SCENE.
     PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
         IF EN-USED(WS-E) = 1 AND EN-TYPE(WS-E) = WS-TYPE
             CALL "ENTITY-REMOVE" USING WS-E
         END-IF
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > HT-MAX
         INITIALIZE HT-ENTRY(WS-I)
     END-PERFORM
     PERFORM VARYING WS-X FROM -3 BY 1 UNTIL WS-X > 3
         PERFORM VARYING WS-Y FROM -3 BY 1 UNTIL WS-Y > 3
             PERFORM VARYING WS-Z FROM -3 BY 1 UNTIL WS-Z > 3
                 COMPUTE WS-NX = WS-HX + WS-X
                 COMPUTE WS-NY = WS-HY + WS-Y
                 COMPUTE WS-NZ = WS-HZ + WS-Z
                 CALL "WORLD-SET-BLOCK" USING WS-DIM WS-NX WS-NY WS-NZ WS-AIR
             END-PERFORM
         END-PERFORM
     END-PERFORM
     COMPUTE WS-NY = WS-HY - 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-NY WS-HZ WS-LOG-Y
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-HY WS-HZ WS-HEART-USE
     COMPUTE WS-NY = WS-HY + 1
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-HX WS-NY WS-HZ WS-LOG-Y
     IF WS-SURROUND > 0
*>       The neighbours of the lower log (y - 1) and of the upper log (y + 1), except the heart cell between them.
         PERFORM VARYING WS-J FROM -1 BY 2 UNTIL WS-J > 1
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 6
                 COMPUTE WS-NX = WS-HX + WS-DX(WS-I)
                 COMPUTE WS-NY = WS-HY + WS-J + WS-DY(WS-I)
                 COMPUTE WS-NZ = WS-HZ + WS-DZ(WS-I)
                 IF NOT (WS-NX = WS-HX AND WS-NZ = WS-HZ AND WS-NY = WS-HY)
                     PERFORM SURROUND-STATE
                     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-NX WS-NY WS-NZ WS-STATE
                 END-IF
             END-PERFORM
         END-PERFORM
     END-IF
     .

*> WS-STATE for the neighbour in direction WS-I of a log (WS-SURROUND).
 SURROUND-STATE.
     EVALUATE WS-SURROUND
         WHEN 2
             MOVE WS-WATER TO WS-STATE
         WHEN 5
             MOVE WS-STONE TO WS-STATE
         WHEN OTHER
             MOVE WS-CLUMP-DEFAULT TO WS-STATE
             PERFORM VARYING WS-DIR FROM 1 BY 1 UNTIL WS-DIR > 6
                 MOVE WS-FACE-NAME(WS-DIR) TO WS-NAME
                 MOVE "true" TO WS-TEXT
*>               The face looking back at the log is the opposite of the step WS-I: the neighbour at step WS-I sees the log on the face WS-I xor 1 (down 1 / up 2, north 3 / south 4, west 5 / east 6).
                 COMPUTE WS-OPP = WS-I + 1 - 2 * FUNCTION MOD(WS-I - 1, 2)
                 IF WS-SURROUND = 4 OR WS-DIR NOT = WS-OPP
                     MOVE 2 TO WS-MODE
                     CALL "BLOCK-STATE-PROP" USING WS-MODE WS-STATE WS-NAME WS-TEXT WS-RESULT
                     MOVE WS-RESULT TO WS-STATE
                 END-IF
             END-PERFORM
     END-EVALUATE
     .

*> The protector: a creaking bound to the heart, 4.5 blocks east of it, linked.
 BIND-PROTECTOR.
     CALL "HEART-FIND" USING WS-DIM WS-HX WS-HY WS-HZ WS-ONE WS-SLOT
     COMPUTE WS-PX = WS-HX + 4.5
     COMPUTE WS-PY = WS-HY
     COMPUTE WS-PZ = WS-HZ + 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-PX WS-PY WS-PZ WS-YAW WS-CROW
     CALL "CREAKING-BIND" USING WS-CROW WS-HX WS-HY WS-HZ
     MOVE EN-ID(WS-CROW) TO HT-LINK(WS-SLOT)
     .

 HIT-CREAKING.
     MOVE 0 TO PL-HURT-COOLDOWN(WS-PLAYER)
     MOVE 3 TO WS-DAMAGE
     MOVE CAUSE-PLAYER TO WS-CAUSE
     CALL "HEALTH-MOB-DAMAGE" USING WS-CROW WS-DAMAGE WS-CAUSE WS-PLAYER
     .

*> The resin faces within three blocks of the heart: WS-FACES the true faces of every resin_clump, WS-ON-LOG those whose neighbour is a pale oak log, WS-WLOGGED the clumps with waterlogged true.
 COUNT-FACES.
     MOVE 0 TO WS-FACES WS-ON-LOG WS-WLOGGED
     PERFORM VARYING WS-X FROM -3 BY 1 UNTIL WS-X > 3
         PERFORM VARYING WS-Y FROM -3 BY 1 UNTIL WS-Y > 3
             PERFORM VARYING WS-Z FROM -3 BY 1 UNTIL WS-Z > 3
                 COMPUTE WS-NX = WS-HX + WS-X
                 COMPUTE WS-NY = WS-HY + WS-Y
                 COMPUTE WS-NZ = WS-HZ + WS-Z
                 CALL "WORLD-GET-BLOCK" USING WS-DIM WS-NX WS-NY WS-NZ WS-STATE
                 IF CB-S-BLOCK(WS-STATE + 1) = WS-RESIN-BLOCK
                     MOVE "waterlogged" TO WS-NAME
                     CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME WS-TEXT WS-RESULT
                     IF WS-TEXT = "true"
                         ADD 1 TO WS-WLOGGED
                     END-IF
                     PERFORM VARYING WS-DIR FROM 1 BY 1 UNTIL WS-DIR > 6
                         MOVE WS-FACE-NAME(WS-DIR) TO WS-NAME
                         CALL "BLOCK-STATE-PROP" USING WS-ONE WS-STATE WS-NAME WS-TEXT WS-RESULT
                         IF WS-TEXT = "true"
                             ADD 1 TO WS-FACES
                             COMPUTE WS-SX = WS-NX + WS-DX(WS-DIR)
                             COMPUTE WS-SY = WS-NY + WS-DY(WS-DIR)
                             COMPUTE WS-SZ = WS-NZ + WS-DZ(WS-DIR)
                             CALL "WORLD-GET-BLOCK" USING WS-DIM WS-SX WS-SY WS-SZ WS-RESULT
                             IF CB-S-BLOCK(WS-RESULT + 1) = WS-LOG-BLOCK
                                 ADD 1 TO WS-ON-LOG
                             END-IF
                         END-IF
                     END-PERFORM
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     .

 SCAN-PACKETS.
     MOVE WS-HX TO SC-HX
     MOVE WS-HY TO SC-HY
     MOVE WS-HZ TO SC-HZ
     MOVE EN-X(WS-CROW) TO SC-CX
     MOVE EN-Y(WS-CROW) TO SC-CY
     MOVE EN-Z(WS-CROW) TO SC-CZ
     CALL "HT5-SCAN" USING WS-CONN WS-SCAN
     .

 ASSERT-LINE.
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 31§6.6 Creaking heart hurt: " DELIMITED BY SIZE FUNCTION TRIM(WS-LABEL) DELIMITED BY SIZE INTO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     .
 END PROGRAM TEST-MOB-20-17-6.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY HEARTTEST.
