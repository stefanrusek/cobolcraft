*> Lane bugbeitems (T42410 and on; operator try15: "the bell doesn't render"): the bell's body and lip (31-4 section 4.4: bell_body box (-3, -6, -3) 6 x 7 x 6, texture (0, 0), part
*> offset (8, 12, 8); bell_base box (4, 4, 4) 8 x 2 x 8, texture (0, 13), 32 x 32 texels, y up like the chest) are drawn by BELL-MESH from the replica's bell list: noted when the block
*> is set (WORLD-BLOCK-SET), rung by Block Event 1 (the parameter is the direction: 2 north, 3 south, 4 west, 5 east), counted by BELL-TICK (ends at 50) and turned about the pivot
*> (8, 12, 8) by the swing a = sin(ticks / pi) / (4 + ticks / 3) (xRot -a north, +a south; zRot -a east, +a west). The expected quads that face the eye (count and the sums over
*> their six vertices: x y z relative to the eye, u and v in texels over 32, times 10000, within 1) come from the independent script client/tests/fixtures/gen_special_items.py
*> (bellmesh). The bell is at (10, 64, 10). The generated vanilla pack is read from CC_GENERATED_DIR.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BELL.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 COPY PROTO.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-CASES-DATA.
    05 FILLER PIC X(70) VALUE "00 105066000850 040+00000000-00354375+00453750+00078750+00096562".
    05 FILLER PIC X(70) VALUE "05 105066000850 043+00000000-00348924+00444614+00078750+00096562".
    05 FILLER PIC X(70) VALUE "20 105066000850 045-00000423-00354373+00453750+00078750+00096562".
    05 FILLER PIC X(70) VALUE "13 105066000850 042+00000000-00351459+00448414+00078750+00096562".
    05 FILLER PIC X(70) VALUE "07 105066000850 044+00006779-00353951+00453750+00078750+00096562".
    05 FILLER PIC X(70) VALUE "00 083062501170 060+00765750+00686250-00405750+00170625+00155625".
    05 FILLER PIC X(70) VALUE "09 083062501170 062+00765750+00687369-00400940+00170625+00155625".
    05 FILLER PIC X(70) VALUE "30 129065201210 063-00837750-00251764-00548953+00196875+00155625".
 01 WS-CASES REDEFINES WS-CASES-DATA.
    05 WS-CASE-ROW OCCURS 8 TIMES.
       10 WS-C-TICKS       PIC 99.
       10 FILLER           PIC X.
       10 WS-C-EX          PIC 9(4).
       10 WS-C-EY          PIC 9(4).
       10 WS-C-EZ          PIC 9(4).
       10 FILLER           PIC X.
       10 WS-C-N           PIC 99.
       10 WS-C-DIR         PIC 9.
       10 WS-C-S           PIC S9(8) SIGN LEADING SEPARATE OCCURS 5 TIMES.
       10 FILLER           PIC X(6).
 01 WS-SPRITE              BINARY-LONG.
 01 WS-ID                  PIC X(80) VALUE "minecraft:entity/bell/bell_body".
 01 WS-ID-LEN              BINARY-LONG VALUE 31.
 01 WS-STATE               BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-CASE                BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-DIR                 BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OBS                 FLOAT-LONG.
 01 WS-EXP                 FLOAT-LONG.
 01 WS-SUM                 FLOAT-LONG OCCURS 5 TIMES.
 01 WS-KT                  PIC 99.
 01 WS-CT                  PIC 99.
 01 WS-EYE-POINT.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-PACKET              BINARY-LONG VALUE 7.
 01 WS-BLOCK-ID            BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO PL-MIN-Y
     MOVE 0 TO SK-U
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     CALL "ATLAS-FIND" USING CLIENT-STATE WS-ID WS-ID-LEN WS-SPRITE
*>   The state of a bell block: the first state whose block is named bell.
     MOVE 0 TO WS-STATE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S >= ST-COUNT OR WS-STATE > 0
         COMPUTE WS-B = ST-BLOCK(WS-S + 1) + 1
         IF ST-BLOCK-NAME(WS-B) = "bell"
             MOVE WS-S TO WS-STATE
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "bugbeitems bell: the sprite entity/bell/bell_body is in the block atlas" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SPRITE > 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The replica holds the cell: a bell is noted when the block is set.
     MOVE 10 TO WS-X
     MOVE 64 TO WS-Y
     MOVE 10 TO WS-Z
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     MOVE "bugbeitems bell: no bell before the block is set" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE "bugbeitems bell: setting the bell block notes the bell" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000 TO CL-NOW-MS
     COMPUTE CL-NEXT-TICK = CL-NOW-MS + 50
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 8
         MOVE 0 TO BL-SHAKING(1) BL-TICKS(1) BL-DIR(1)
         MOVE WS-C-DIR(WS-CASE) TO WS-DIR
         IF WS-C-TICKS(WS-CASE) > 0
             CALL "BELL-EVENT" USING CLIENT-STATE WS-X WS-Y WS-Z WS-ONE WS-DIR
             PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > WS-C-TICKS(WS-CASE)
                 CALL "BELL-TICK" USING CLIENT-STATE
             END-PERFORM
         END-IF
         COMPUTE WS-EYE(1) = WS-C-EX(WS-CASE) / 100
         COMPUTE WS-EYE(2) = WS-C-EY(WS-CASE) / 100
         COMPUTE WS-EYE(3) = WS-C-EZ(WS-CASE) / 100
         MOVE 0 TO RL-GI-COUNT
         CALL "BELL-MESH" USING CLIENT-STATE WS-EYE-POINT
         MOVE WS-CASE TO WS-CT
         MOVE SPACES TO TL-CASE
         STRING "bugbeitems bell case " WS-CT ": the quads that face the eye" DELIMITED BY SIZE INTO TL-CASE
         MOVE "N" TO TL-MODE
         MOVE WS-C-N(WS-CASE) TO TL-EXPECTED-N
         COMPUTE TL-OBSERVED-N = RL-GI-COUNT / 6
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
             MOVE 0 TO WS-SUM(WS-K)
         END-PERFORM
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > RL-GI-COUNT
             COMPUTE WS-SUM(1) = WS-SUM(1) + RL-GI-X(WS-I)
             COMPUTE WS-SUM(2) = WS-SUM(2) + RL-GI-Y(WS-I)
             COMPUTE WS-SUM(3) = WS-SUM(3) + RL-GI-Z(WS-I)
             COMPUTE WS-SUM(4) = WS-SUM(4) + (RL-GI-U(WS-I) * AT-W - AT-X(WS-SPRITE)) / AT-SW(WS-SPRITE)
             COMPUTE WS-SUM(5) = WS-SUM(5) + (RL-GI-V(WS-I) * AT-H - AT-Y(WS-SPRITE)) / AT-SH(WS-SPRITE)
         END-PERFORM
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 5
             MOVE WS-CASE TO WS-CT
             MOVE WS-K TO WS-KT
             MOVE SPACES TO TL-CASE
             STRING "bugbeitems bell case " WS-CT ": sum of the vertices, component " WS-KT DELIMITED BY SIZE INTO TL-CASE
             COMPUTE WS-EXP = WS-C-S(WS-CASE, WS-K) / 10000
             MOVE WS-SUM(WS-K) TO WS-OBS
             PERFORM CHECK-NEAR
         END-PERFORM
     END-PERFORM
*>   The swing ends at 50 ticks (31-4 4.3 step 2).
     CALL "BELL-EVENT" USING CLIENT-STATE WS-X WS-Y WS-Z WS-ONE WS-THREE
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 49
         CALL "BELL-TICK" USING CLIENT-STATE
     END-PERFORM
     MOVE "bugbeitems bell: still shaking at tick 49" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BL-SHAKING(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BELL-TICK" USING CLIENT-STATE
     MOVE "bugbeitems bell: the swing stops at tick 50 (ticks 0, not shaking)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BL-SHAKING(1) + BL-TICKS(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A Block Event packet (id 7) reaches the bell: position, action 1, parameter 4 (west), block id.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 4 TO WS-DIR
     MOVE 0 TO WS-BLOCK-ID
     CALL "PB-PUT-BLOCK-EVENT" USING PB-BUFFER WS-X WS-Y WS-Z WS-ONE WS-DIR WS-BLOCK-ID
     MOVE 0 TO PB-POS
     MOVE PH-PLAY TO CN-PHASE(1)
     CALL "PROTO-PACKET" USING CLIENT-STATE WS-ONE PB-BUFFER WS-PACKET
     MOVE "bugbeitems bell: Block Event 1 with parameter 4 starts the swing west" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = BL-SHAKING(1) * 10 + BL-DIR(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A block event of another action changes nothing; the chunk's bells are forgotten with it.
     MOVE 0 TO BL-SHAKING(1)
     CALL "BELL-EVENT" USING CLIENT-STATE WS-X WS-Y WS-Z WS-ZERO WS-THREE
     MOVE "bugbeitems bell: another action does not ring" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BL-SHAKING(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 5 TO WS-CX WS-CZ
     CALL "BELL-FORGET" USING CLIENT-STATE WS-CX WS-CZ
     MOVE "bugbeitems bell: the bell of another chunk stays" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE BL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The block is replaced: the next tick drops the bell.
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-AIR
     CALL "BELL-TICK" USING CLIENT-STATE
     MOVE "bugbeitems bell: the bell is dropped when its block is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A chunk that has just loaded is scanned: a second bell set into the replica's cell without a note is found by BELL-SCAN.
     CALL "WORLD-BLOCK-SET" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 11 TO WS-X
     MOVE 11 TO WS-Z
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-CX WS-CZ
     CALL "BELL-SCAN" USING CLIENT-STATE WS-CX WS-CZ
     MOVE "bugbeitems bell: scanning the loaded chunk finds both bells" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE BL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "WORLD-FORGET" USING CLIENT-STATE WS-CX WS-CZ
     MOVE "bugbeitems bell: Forget Level Chunk drops the chunk's bells" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "BELL-SCAN" USING CLIENT-STATE WS-CX WS-CZ
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     MOVE "bugbeitems bell: clearing the replica drops the bells" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE BL-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 CHECK-NEAR.
     MOVE "N" TO TL-MODE
     COMPUTE TL-EXPECTED-N ROUNDED = WS-EXP * 10000
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OBS * 10000
     IF FUNCTION ABS(TL-EXPECTED-N - TL-OBSERVED-N) <= 1
         MOVE TL-EXPECTED-N TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-BELL.

 COPY CLTEST.
