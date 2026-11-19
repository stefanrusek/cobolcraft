*> Acceptance test (lane bugbounce, T61202; operator report "beds and slime blocks are not bouncy"; docs/protocol/24-5 slime_block, hay_block and Block.fallOn rows, 24-2 beds,
*> 17 section 4.11 fall formula floor((distance + 1e-6 - 3) x multiplier)): a survival player who lands on the standard world's blocks after a fall of 10 blocks (Move Player
*> packets with on-ground) takes 7 health on stone (control), none on slime (damage multiplier 0, also when sneaking: the method calls nothing), 1 on hay (multiplier 0.2:
*> floor(7 x 0.2)) and 2 on a bed (distance halved: floor(5 - 3)), and the landing key rules are right for the other blocks.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BOUNCE-FALL-DAMAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY BRWORLD.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-BLOCK               BINARY-LONG.
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-STATE-TEXT          PIC X(5).
 01 WS-STATE               BINARY-LONG.
 01 WS-BX                  BINARY-LONG VALUE 20.
 01 WS-BY                  BINARY-LONG VALUE 100.
 01 WS-BZ                  BINARY-LONG VALUE 20.
 01 WS-MOVE                BINARY-LONG VALUE 30.
 01 WS-FX                  FLOAT-LONG VALUE 20.5.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG VALUE 20.5.
 01 WS-FLOOR               FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 01 WS-FLAGS               BINARY-LONG.
 01 WS-TICKS               BINARY-LONG.
 01 WS-TEXT                PIC X(4096).
 01 WS-BEFORE              BINARY-LONG.
 01 WS-AFTER               BINARY-LONG.
 01 WS-LOST                BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FACTOR              FLOAT-LONG.
 01 WS-MULT                FLOAT-LONG.
 01 WS-F-MILLI             PIC 9(5).
 01 WS-M-MILLI             PIC 9(5).
 01 WS-OBS                 PIC X(40).
 01 WS-KEYS.
    05 FILLER              PIC X(32) VALUE "minecraft:stone".
    05 FILLER              PIC X(32) VALUE "minecraft:slime_block".
    05 FILLER              PIC X(32) VALUE "minecraft:hay_block".
    05 FILLER              PIC X(32) VALUE "minecraft:white_bed".
 01 WS-KEY-TABLE REDEFINES WS-KEYS.
    05 WS-FLOOR-KEY        PIC X(32) OCCURS 4 TIMES.
 01 WS-RULES.
    05 FILLER              PIC X(48) VALUE "minecraft:stone".
    05 FILLER              PIC X(48) VALUE "slime_block".
    05 FILLER              PIC X(48) VALUE "minecraft:hay_block".
    05 FILLER              PIC X(48) VALUE "honey_block".
    05 FILLER              PIC X(48) VALUE "minecraft:red_bed".
    05 FILLER              PIC X(48) VALUE "shelf_mushroom".
    05 FILLER              PIC X(48) VALUE "minecraft:bedrock".
 01 WS-RULE-TABLE REDEFINES WS-RULES.
    05 WS-RULE-KEY         PIC X(48) OCCURS 7 TIMES.
 01 WS-WANT.
    05 FILLER              PIC X(11) VALUE "01000 01000".
    05 FILLER              PIC X(11) VALUE "01000 00000".
    05 FILLER              PIC X(11) VALUE "01000 00200".
    05 FILLER              PIC X(11) VALUE "01000 00200".
    05 FILLER              PIC X(11) VALUE "00500 01000".
    05 FILLER              PIC X(11) VALUE "00500 01000".
    05 FILLER              PIC X(11) VALUE "01000 01000".
 01 WS-WANT-TABLE REDEFINES WS-WANT.
    05 WS-RULE-WANT        PIC X(11) OCCURS 7 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
*>   The block shapes (51: a bed is 9/16 high, its collision box carries the player's feet).
     CALL "BSH-BUILD"
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE 0 TO PL-MODE(WS-ROW)
     MOVE 17 TO PL-FOOD(WS-ROW)
     MOVE 0 TO PL-SATURATION(WS-ROW)
     MOVE "N" TO TL-MODE
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 4
         MOVE SPACES TO WS-KEY
         MOVE WS-FLOOR-KEY(WS-K) TO WS-KEY
         CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
         MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
         COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
*>       A floor cell of the key, the player standing on it, then a fall of 10 blocks (rise with on-ground false, land with on-ground true).
         COMPUTE WS-BY = 100 + WS-K * 0
         COMPUTE WS-BX = 20 + WS-K * 3
         CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
         COMPUTE WS-FX = WS-BX + 0.5
         MOVE 101 TO WS-FLOOR
         IF WS-K = 4
             MOVE 100.5625 TO WS-FLOOR
         END-IF
         COMPUTE WS-FY = WS-FLOOR + 10
         MOVE 0 TO WS-FLAGS
         CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
         MOVE 20 TO WS-TICKS
         CALL "TEST-TICKS" USING WS-TICKS
         MOVE 20 TO PL-HEALTH(WS-ROW)
         MOVE WS-FLOOR TO WS-FY
         MOVE 1 TO WS-FLAGS
         CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
         COMPUTE WS-LOST = 20 - PL-HEALTH(WS-ROW)
         EVALUATE WS-K
             WHEN 1
                 MOVE "bounce fall: 10 blocks onto stone cost 7 health (control)" TO TL-CASE
                 MOVE 7 TO TL-EXPECTED-N
             WHEN 2
                 MOVE "bounce fall: 10 blocks onto slime cost nothing (damage multiplier 0)" TO TL-CASE
                 MOVE 0 TO TL-EXPECTED-N
             WHEN 3
                 MOVE "bounce fall: 10 blocks onto hay cost floor(7 x 0.2) = 1" TO TL-CASE
                 MOVE 1 TO TL-EXPECTED-N
             WHEN OTHER
                 MOVE "bounce fall: 10 blocks onto a bed cost floor(10 x 0.5 - 3) = 2" TO TL-CASE
                 MOVE 2 TO TL-EXPECTED-N
         END-EVALUATE
         MOVE WS-LOST TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE 12 TO WS-TICKS
         CALL "TEST-TICKS" USING WS-TICKS
         MOVE 20 TO PL-HEALTH(WS-ROW)
     END-PERFORM
*>   Sneaking on slime: the doc's fallOn calls nothing, so no damage either.
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:slime_block" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BLOCK WS-BLOCK-ROW WS-STATUS
     MOVE WS-BLOCK-ROW(1 + 4 + 35 + 32 + 288 + 4 + 5:5) TO WS-STATE-TEXT
     COMPUTE WS-STATE = FUNCTION NUMVAL(WS-STATE-TEXT)
     MOVE 40 TO WS-BX
     CALL "WORLD-SET-BLOCK" USING WS-DIM WS-BX WS-BY WS-BZ WS-STATE
     COMPUTE WS-FX = WS-BX + 0.5
     MOVE 111 TO WS-FY
     MOVE 0 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     MOVE 1 TO PL-SNEAKING(WS-ROW)
     MOVE 101 TO WS-FY
     MOVE 1 TO WS-FLAGS
     CALL "TEST-MOVE" USING WS-ALICE WS-MOVE WS-FX WS-FY WS-FZ WS-YAW WS-PITCH WS-FLAGS
     COMPUTE WS-LOST = 20 - PL-HEALTH(WS-ROW)
     MOVE "bounce fall: a sneaking player landing on slime takes no damage" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-LOST TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The landing rules by key: distance factor and damage multiplier in thousandths.
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 7
         CALL "FALL-ON-KEY" USING WS-RULE-KEY(WS-K) WS-FACTOR WS-MULT
         COMPUTE WS-F-MILLI ROUNDED = WS-FACTOR * 1000
         COMPUTE WS-M-MILLI ROUNDED = WS-MULT * 1000
         MOVE SPACES TO WS-OBS
         STRING WS-F-MILLI " " WS-M-MILLI DELIMITED BY SIZE INTO WS-OBS
         MOVE SPACES TO TL-CASE
         STRING "bounce fall rule: " FUNCTION TRIM(WS-RULE-KEY(WS-K)) DELIMITED BY SIZE INTO TL-CASE
         MOVE SPACE TO TL-MODE
         MOVE WS-RULE-WANT(WS-K) TO TL-EXPECTED
         MOVE WS-OBS TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM ACC-BOUNCE-FALL-DAMAGE.

 COPY CORETEST.
