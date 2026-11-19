*> Acceptance test (002-lane-bugflatspawn; operator report on try16: "hostile mobs aren't spawning in my super flat world at night"; 18 sections 6.1, 6.3, 6.11): a superflat world
*> (the default `flat` preset, seed 12345, difficulty normal, hostile mobs on) from the generated vanilla data (CC_GENERATED_DIR; skipped as a pass without it), a creative player in the
*> open, the world time set to night (14000), 600 ticks run. Expected: the natural spawner makes several hostile mobs. Then the player is taken 3000 blocks away (the flat world invites
*> travel; the mobs of the first place are more than 128 blocks from the only player) at night again: hostile mobs spawn round the player again within 600 ticks. They did not: the
*> mobs left behind were never despawn-checked (MOBS-TICK stepped, and checked, only mobs within 64 blocks of a player), stayed in the monster category's global count (cap 70) and
*> blocked every new spawn. The client answers the keep-alives (TEST-TICKS-ANSWERED).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFLATSPAWN-NIGHT.
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
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-HOSTILE             BINARY-LONG.
 01 WS-NEARP               BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-D2                  FLOAT-LONG.
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
         MOVE "acc bugflatspawn no generated packs here, skipped" TO TL-CASE
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
     MOVE 600 TO WS-LEN
     PERFORM RUN-NIGHT
     MOVE WS-HOSTILE TO WS-FIRST
     MOVE "N" TO TL-MODE
     MOVE "acc bugflatspawn by night in a new superflat world several hostile mobs spawn" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HOSTILE >= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 3000.5 TO PL-X(WS-PLAYER)
     MOVE 3000.5 TO PL-Z(WS-PLAYER)
     CALL "CHUNKS-FOLLOW" USING WS-CONN
     PERFORM RUN-NIGHT
     MOVE "acc bugflatspawn after the player went 3000 blocks away hostile mobs spawn round the new place by night" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NEARP >= 3
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acc bugflatspawn the hostile mobs left 3000 blocks behind are gone (they are beyond 128 blocks of the only player)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-HOSTILE - WS-NEARP
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> Sets the time to 14000, runs WS-LEN ticks (the keep-alives answered, the packets drained) and counts the standard hostile mobs (WS-HOSTILE) and those within 128 blocks of the player (WS-NEARP).
 RUN-NIGHT.
     MOVE 14000 TO CW-TIME
     PERFORM VARYING WS-TICK FROM 20 BY 20 UNTIL WS-TICK > WS-LEN
         CALL "TEST-TICKS-ANSWERED" USING WS-TWENTY
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
         CALL "PB-FREE" USING PB-BUFFER
     END-PERFORM
     MOVE 0 TO WS-HOSTILE WS-NEARP
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND WS-ROW NOT = PL-ENTITY-ROW(WS-PLAYER)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0
                 IF SM-KIND(WS-S) = 1
                     ADD 1 TO WS-HOSTILE
                     COMPUTE WS-DX = EN-X(WS-ROW) - PL-X(WS-PLAYER)
                     COMPUTE WS-DZ = EN-Z(WS-ROW) - PL-Z(WS-PLAYER)
                     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DZ * WS-DZ
                     IF WS-D2 < 16384
                         ADD 1 TO WS-NEARP
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM.
 END PROGRAM ACC-BUGFLATSPAWN-NIGHT.
 COPY CORETEST.
