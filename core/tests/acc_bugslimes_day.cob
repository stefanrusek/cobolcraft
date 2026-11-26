*> Acceptance test (002-lane-bugslimes; operator report on try18: "Superflat is normally flooded with slimes ... hostile mobs have gone from too common to rare"; 20 section 10,
*> 54 section 8.1, 18 sections 6.1, 6.3, 6.8): a new superflat world (default flat preset, surface at y -60, seed 12345, hostile mobs on), a creative player standing still, the world
*> time held at 1000 (full day, no moon issue) for 1000 ticks. A slime may spawn at any light level in a slime chunk below y 40 (20 section 10 (b)), so by day, when no zombie, skeleton,
*> spider or creeper can spawn (light), the slimes fill the monster category. Expected: many slimes (the monster cap is 70 x chunks / 289), all of the sizes 1, 2 and 4 among them, almost all
*> standing in a slime chunk (they spawn there and hop slowly), and no light-bound monster.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGSLIMES-DAY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY FLATSET.
 COPY PROTO.
 COPY STDMOBS.
 COPY BRWORLD.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Stefan".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 6.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CLOSE               BINARY-LONG.
 01 WS-TWENTY              BINARY-LONG VALUE 20.
 01 WS-TICK                BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-ISSLIME             BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-SKELETON            BINARY-LONG.
 01 WS-SPIDER              BINARY-LONG.
 01 WS-CREEPER             BINARY-LONG.
 01 WS-SLIMES              BINARY-LONG.
 01 WS-INCHUNK             BINARY-LONG.
 01 WS-SIZE1               BINARY-LONG.
 01 WS-SIZE2               BINARY-LONG.
 01 WS-SIZE4               BINARY-LONG.
 01 WS-NEAR                BINARY-LONG.
 01 WS-FAR                 BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
 01 WS-WALK                FLOAT-LONG.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-ENV
     ACCEPT WS-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR
     ELSE
         MOVE WS-ENV TO WS-DIR
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acc bugslimes no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE 8 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Flat" TO CS-NEW-WORLD-NAME
     MOVE 0 TO FS-PENDING
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 1 TO PL-MODE(WS-PLAYER)
     MOVE 0.5 TO PL-X(WS-PLAYER)
     MOVE 0.5 TO PL-Z(WS-PLAYER)
     CALL "CHUNKS-FOLLOW" USING WS-CONN
     MOVE 1000 TO WS-START
     MOVE 1000 TO WS-LEN
     PERFORM RUN-TICKS
     MOVE "N" TO TL-MODE
     MOVE "acc bugslimes by day in a new superflat world at least 20 slimes spawn in 1000 ticks" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLIMES >= 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acc bugslimes by day no zombie, skeleton, spider or creeper spawns (light)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ZOMBIE + WS-SKELETON + WS-SPIDER + WS-CREEPER = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acc bugslimes sizes 1, 2 and 4 all occur among the natural slimes (20 section 10: 1 shifted left by nextInt(3))" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SIZE1 > 0 AND WS-SIZE2 > 0 AND WS-SIZE4 > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acc bugslimes at least 80 percent of the slimes stand in a slime chunk (54 section 8.1)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-INCHUNK * 5 >= WS-SLIMES * 4
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Holds the world time at WS-START and runs WS-LEN ticks (keep-alives answered, packets drained), then counts the standard mobs within 128 blocks of the player (WS-ZOMBIE ...
*> WS-SLIMES with their sizes and the number standing in a slime chunk, WS-OTHER the other hostile ones) and the hostile ones beyond (WS-FAR).
 RUN-TICKS.
     PERFORM VARYING WS-TICK FROM 20 BY 20 UNTIL WS-TICK > WS-LEN
         MOVE WS-START TO CW-TIME
         CALL "TEST-TICKS-ANSWERED" USING WS-TWENTY
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
         CALL "PB-FREE" USING PB-BUFFER
     END-PERFORM
     MOVE 0 TO WS-ZOMBIE WS-SKELETON WS-SPIDER WS-CREEPER WS-SLIMES WS-INCHUNK WS-SIZE1 WS-SIZE2 WS-SIZE4 WS-FAR WS-OTHER
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND WS-ROW NOT = PL-ENTITY-ROW(WS-PLAYER)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0 AND SM-KIND(WS-S) = 1
                 COMPUTE WS-DX = EN-X(WS-ROW) - PL-X(WS-PLAYER)
                 COMPUTE WS-DZ = EN-Z(WS-ROW) - PL-Z(WS-PLAYER)
                 COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
                 IF WS-D2 >= 16384
                     ADD 1 TO WS-FAR
                 ELSE
                     EVALUATE SM-KEY(WS-S)
                         WHEN "zombie"
                             ADD 1 TO WS-ZOMBIE
                         WHEN "skeleton"
                             ADD 1 TO WS-SKELETON
                         WHEN "spider"
                             ADD 1 TO WS-SPIDER
                         WHEN "creeper"
                             ADD 1 TO WS-CREEPER
                         WHEN "slime"
                             ADD 1 TO WS-SLIMES
                             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
                             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
                             CALL "M44-SLIME-CHUNK" USING WS-CX WS-CZ CW-SEED WS-ISSLIME
                             ADD WS-ISSLIME TO WS-INCHUNK
                             MOVE EN-VARIANT(WS-ROW) TO WS-SIZE
                             EVALUATE WS-SIZE
                                 WHEN 0 ADD 1 TO WS-SIZE1
                                 WHEN 1 ADD 1 TO WS-SIZE1
                                 WHEN 2 ADD 1 TO WS-SIZE2
                                 WHEN 4 ADD 1 TO WS-SIZE4
                             END-EVALUATE
                         WHEN OTHER
                             ADD 1 TO WS-OTHER
                     END-EVALUATE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     DISPLAY "bugslimes zombie=" WS-ZOMBIE " skeleton=" WS-SKELETON " spider=" WS-SPIDER " creeper=" WS-CREEPER " slime=" WS-SLIMES " (in slime chunk " WS-INCHUNK
         ", size 1/2/4 " WS-SIZE1 "/" WS-SIZE2 "/" WS-SIZE4 ") other=" WS-OTHER " beyond128=" WS-FAR.
 END PROGRAM ACC-BUGSLIMES-DAY.
 COPY CORETEST.
