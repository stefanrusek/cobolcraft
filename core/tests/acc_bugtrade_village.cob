*> Acceptance test (002-lane-bugtrade; operator report try15: "can't interact with villagers (farmer)"): a superflat world (the default `flat` preset, seed 12345) from the
*> generated vanilla data (CC_GENERATED_DIR; a pass without it), its first village generated round the player, then a villager of that village (not placed by the test: the
*> one the generator made) is right clicked through the real Interact packet (05c 0x1A). Expected (40 section 2.1, 19 sections 22.4): a villager with a profession that is
*> neither none nor nitwit opens the merchant window (Open Screen 0x3C of menu type 19 then Merchant Offers 0x35) wherever it is within reach; one without a profession (or a nitwit)
*> opens nothing; nor does a baby (19 section 22.4: a baby villager is refused) or a villager asleep (it is ignored). The villagers take their professions as in the game (a
*> workstation of the village, CORE-TICK), they are not set. The client half of the report (the look ray never met a villager: its registry category is MISC) is
*> acc_bugtrade_villager_target in the client.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGTRADE-VILLAGE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY FLATSET.
 COPY STRUCTDATA.
 COPY PROTO.
 COPY STDMOBS.
 COPY VILSTATE.
 COPY CMENU.
 01 WS-FIRST-ROW           BINARY-LONG VALUE 0.
 01 WS-BABY                BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 01 WS-BABY-D              PIC 9.
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
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-VILLAGES            BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-KEY80               PIC X(80).
 01 WS-VKEY                PIC X(80).
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-TICK                BINARY-LONG.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-CENSUS              BINARY-LONG VALUE 0.
 01 WS-WITH-PROF           BINARY-LONG VALUE 0.
 01 WS-PICK                BINARY-LONG VALUE 0.
 01 WS-PICK-ID             BINARY-LONG VALUE 0.
 01 WS-PICK-SLOT           BINARY-LONG VALUE 0.
 01 WS-IDS                 PIC X(1024).
 01 WS-SPACED              PIC X(1030).
 01 WS-N60                 PIC 9.
 01 WS-N53                 PIC 9.
 01 WS-N1                  PIC -(5)9.
 01 WS-N2                  PIC -(5)9.
 01 WS-N3                  PIC -(5)9.
 01 WS-N4                  PIC -(5)9.
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
         MOVE "acc bugtrade no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 0 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Flat" TO CS-NEW-WORLD-NAME
     MOVE 0 TO FS-PENDING
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-SEED TO WS-SEED
     PERFORM SCAN-STARTS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE PL-X(WS-PLAYER) = WS-VX * 16 + 8.5
     MOVE -60 TO PL-Y(WS-PLAYER)
     COMPUTE PL-Z(WS-PLAYER) = WS-VZ * 16 + 8.5
     CALL "CHUNKS-FOLLOW" USING WS-CONN
     PERFORM DRAIN
     PERFORM CENSUS-VILLAGERS
*>   Since lane p49h a villager with no claimed job site, no experience and level 1 loses its profession on the brain beat (44-3 section 2.2, as in the game): the generated
*>   villagers here claim no job site in 600 ticks, so each villager the village is made with is given the experience of a trade on the tick it appears (KEEP-PROFESSIONS)
*>   and keeps its generated profession while the window is tried.
     PERFORM VARYING WS-TICK FROM 1 BY 1 UNTIL WS-TICK > 600
         IF FUNCTION MOD(WS-TICK, 20) = 1
             MOVE 6000 TO CW-TIME
         END-IF
         MOVE 999999999 TO CN-KA-DEADLINE(WS-CONN)
         CALL "TEST-TICKS" USING WS-ONE
         PERFORM KEEP-PROFESSIONS
         IF FUNCTION MOD(WS-TICK, 20) = 0
             PERFORM DRAIN
         END-IF
     END-PERFORM
     PERFORM CENSUS-VILLAGERS
     PERFORM TRY-EACH
     PERFORM STAYS-OPEN
     MOVE "N" TO TL-MODE
     MOVE "acc bugtrade the village has a villager with a profession" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-WITH-PROF > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acc bugtrade the village has villagers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CENSUS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 DRAIN.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     CALL "PB-FREE" USING PB-BUFFER.

 TRY-EACH.
     MOVE "T" TO TL-MODE
*>   A villager with a profession: a baby or a sleeper opens nothing (checked before any window is open).
     MOVE 0 TO WS-FIRST-ROW
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT OR WS-FIRST-ROW > 0
         IF EN-USED(WS-ROW) = 1 AND WS-ROW NOT = PL-ENTITY-ROW(WS-PLAYER)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0 AND SM-KEY(WS-S) = "villager"
                 CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
                 IF VL-PROF(WS-SLOT) NOT = "none" AND VL-PROF(WS-SLOT) NOT = "nitwit"
                     MOVE WS-ROW TO WS-FIRST-ROW
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-FIRST-ROW TO WS-ROW
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
     MOVE EN-VARIANT(WS-ROW) TO WS-BABY
     MOVE 1 TO EN-VARIANT(WS-ROW)
     MOVE "acc bugtrade 19 22.4 a baby villager with a profession opens no window" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     PERFORM INTERACT-ROW
     MOVE WS-BABY TO EN-VARIANT(WS-ROW)
     MOVE 1 TO VL-SLEEP(WS-SLOT)
     MOVE "acc bugtrade 19 22.4 a sleeping villager opens no window" TO TL-CASE
     MOVE "0 0" TO TL-EXPECTED
     PERFORM INTERACT-ROW
     MOVE 0 TO VL-SLEEP(WS-SLOT)
*>   Every villager of the village, as the generator and the game made it.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND WS-ROW NOT = PL-ENTITY-ROW(WS-PLAYER)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0 AND SM-KEY(WS-S) = "villager"
                 CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
                 MOVE "0 0" TO TL-EXPECTED
                 IF VL-PROF(WS-SLOT) NOT = "none" AND VL-PROF(WS-SLOT) NOT = "nitwit" AND EN-VARIANT(WS-ROW) NOT = 1
                     MOVE "1 1" TO TL-EXPECTED
                 END-IF
                 MOVE EN-VARIANT(WS-ROW) TO WS-BABY-D
                 MOVE SPACES TO TL-CASE
                 STRING "acc bugtrade 40 2.1 Interact on a village villager (" FUNCTION TRIM(VL-PROF(WS-SLOT)) ", baby "
                     WS-BABY-D ") opens the trades only with a profession and grown up" DELIMITED BY SIZE INTO TL-CASE
                 PERFORM INTERACT-ROW
             END-IF
         END-IF
     END-PERFORM.

*> The player stands 1.2 blocks east of the villager of row WS-ROW (the generator's villager, where it is) and right clicks it; TL-OBSERVED is "<Open Screen> <Merchant Offers>".
 INTERACT-ROW.
     COMPUTE PL-X(WS-PLAYER) = EN-X(WS-ROW) + 1.2
     MOVE EN-Y(WS-ROW) TO PL-Y(WS-PLAYER)
     MOVE EN-Z(WS-ROW) TO PL-Z(WS-PLAYER)
     PERFORM DRAIN
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-ROW) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE SPACES TO WS-SPACED
     STRING " " WS-IDS DELIMITED BY SIZE INTO WS-SPACED
     MOVE 0 TO WS-N60 WS-N53
     INSPECT WS-SPACED TALLYING WS-N60 FOR ALL " 60 " ALL " 60x"
     INSPECT WS-SPACED TALLYING WS-N53 FOR ALL " 53 " ALL " 53x"
     IF WS-N60 > 1
         MOVE 1 TO WS-N60
     END-IF
     IF WS-N53 > 1
         MOVE 1 TO WS-N53
     END-IF
     MOVE SPACES TO TL-OBSERVED
     STRING WS-N60 " " WS-N53 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 STAYS-OPEN.
     MOVE "T" TO TL-MODE
*>   The window of a villager that opened stays open on the next ticks (the player is 1.2 blocks from it), and closes (Container Close, 17) once she is 10 blocks away.
     MOVE WS-FIRST-ROW TO WS-ROW
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
     MOVE 0 TO VL-SLEEP(WS-SLOT)
     MOVE 0 TO EN-VARIANT(WS-ROW)
     MOVE "1 1" TO TL-EXPECTED
     MOVE "acc bugtrade 40 2.9 the villager with a profession opens the trades again" TO TL-CASE
     PERFORM INTERACT-ROW
     MOVE 999999999 TO CN-KA-DEADLINE(WS-CONN)
     MOVE 3 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE "acc bugtrade 40 2.9 three ticks later the trading window is still open (the villager is within 4 blocks)" TO TL-CASE
     MOVE "open" TO TL-EXPECTED
     MOVE "closed" TO TL-OBSERVED
     IF MN-WINDOW(WS-PLAYER) > 0
         MOVE "open" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE PL-X(WS-PLAYER) = PL-X(WS-PLAYER) + 10
     MOVE 3 TO WS-N
     CALL "TEST-TICKS" USING WS-N
     MOVE "acc bugtrade 40 2.9 ten blocks from the villager the trading window is closed" TO TL-CASE
     MOVE "closed" TO TL-EXPECTED
     MOVE "open" TO TL-OBSERVED
     IF MN-WINDOW(WS-PLAYER) = 0
         MOVE "closed" TO TL-OBSERVED
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 KEEP-PROFESSIONS.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND WS-ROW NOT = PL-ENTITY-ROW(WS-PLAYER)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0
                 IF SM-KEY(WS-S) = "villager"
                     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
                     IF WS-SLOT > 0
                         IF VL-PROF(WS-SLOT) NOT = "none" AND VL-PROF(WS-SLOT) NOT = "nitwit"
                             MOVE 1 TO VL-XP(WS-SLOT)
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM.
 CENSUS-VILLAGERS.
     MOVE 0 TO WS-CENSUS WS-WITH-PROF WS-PICK-ID
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND WS-ROW NOT = PL-ENTITY-ROW(WS-PLAYER)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0
                 IF SM-KEY(WS-S) = "villager"
                     ADD 1 TO WS-CENSUS
                     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
                     IF WS-SLOT > 0
                         IF VL-PROF(WS-SLOT) NOT = "none" AND VL-PROF(WS-SLOT) NOT = "nitwit"
                             ADD 1 TO WS-WITH-PROF
                         END-IF
                     END-IF
                 END-IF
             END-IF
         END-IF
     END-PERFORM.

 SCAN-STARTS.
     MOVE 0 TO WS-VILLAGES WS-VX WS-VZ
     IF SD-POSS-DONE = 0
         CALL "STRUCT-POSSIBLE-BUILD"
     END-IF
     PERFORM VARYING WS-CX FROM -24 BY 1 UNTIL WS-CX > 24
         PERFORM VARYING WS-CZ FROM -24 BY 1 UNTIL WS-CZ > 24
             CALL "STRUCT-CHUNK-STARTS" USING WS-SEED WS-CX WS-CZ WS-COUNT
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
                 MOVE SDT-KEY(SC-STRUCT(WS-J)) TO WS-KEY80
                 IF WS-KEY80(1:18) = "minecraft:village_" AND WS-VILLAGES = 0
                     MOVE WS-CX TO WS-VX
                     MOVE WS-CZ TO WS-VZ
                     MOVE WS-KEY80 TO WS-VKEY
                     ADD 1 TO WS-VILLAGES
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM.
 END PROGRAM ACC-BUGTRADE-VILLAGE.
 COPY CORETEST.
