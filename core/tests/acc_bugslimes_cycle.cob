*> Acceptance test (002-lane-bugslimes; operator report on try18, 18 sections 6.1, 6.3, 6.11): a new superflat world, a creative player. Night (time held at 14000) for 1500 ticks: zombies, skeletons,
*> spiders and creepers spawn (light 0 to 7 after the sky darkening). Then the player goes 1000 blocks away (a flat world invites it) and it is day (time held at 1000) for 1000 ticks. The
*> mobs of the night are more than 128 blocks away: they are despawn-checked wherever they stand (6.11), so they leave the monster category's count and the slimes (any light, slime chunks)
*> fill it round the new place. Before the fix of MOBS-TICK (lane bugflatspawn) the night's mobs stayed for good, held the cap, and no mob spawned by day: 82 hostile mobs stood beyond 128
*> blocks, none within.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGSLIMES-CYCLE.
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
     MOVE 14000 TO WS-START
     MOVE 1500 TO WS-LEN
     PERFORM RUN-TICKS
     MOVE "N" TO TL-MODE
     MOVE "acc bugslimes by night every one of zombie, skeleton, spider and creeper spawns" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-ZOMBIE > 0 AND WS-SKELETON > 0 AND WS-SPIDER > 0 AND WS-CREEPER > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1000.5 TO PL-X(WS-PLAYER)
     MOVE 1000.5 TO PL-Z(WS-PLAYER)
     CALL "CHUNKS-FOLLOW" USING WS-CONN
     MOVE 1000 TO WS-START
     MOVE 1000 TO WS-LEN
     PERFORM RUN-TICKS
     MOVE "N" TO TL-MODE
     MOVE "acc bugslimes the player 1000 blocks away by day: at least 20 slimes round the new place" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SLIMES >= 20
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     MOVE "acc bugslimes the hostile mobs of the first night are gone (none beyond 128 blocks of the only player)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FAR = 0
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
 END PROGRAM ACC-BUGSLIMES-CYCLE.
 COPY CORETEST.
