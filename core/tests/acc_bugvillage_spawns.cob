*> Acceptance test (002-lane-bugvillage; operator report: "I created a superflat world, and as I approached a village zombies started attacking the villagers, and spiders
*> appeared on roofs, and creepers appeared"): a superflat world (the default `flat` preset, seed 12345) from the generated vanilla data (CC_GENERATED_DIR; skipped as a pass
*> without it), its first village (found by the structure scan as test_flat_column does) generated round a creative player, and the natural spawner run for 300 ticks by day and
*> 300 by night with every new mob recorded (species, cell, stored sky and block light, what lies above and below). Hostile mobs are taken away as they appear, so the cap does
*> not stop the spawning. Expected (18 section 6.8, 6.9; 32 section 5.2):
*>   - the village census holds villagers and no hostile mob (a plains village has no zombie villagers);
*>   - by day a hostile mob spawns only where the sky does not shine in: never in a cell beside which, on one of the four sides, the open sky begins (under the eaves of a house or
*>     a porch roof the stored light reads 0 but the sky engine's spread gives 13 or 14); a closed dark room can still spawn one (no torches: that is vanilla, and the wall torch gave
*>     no light before its own fix);
*>   - no mob spawns on a floor whose top face is not sturdy: a bed, a carpet, farmland, a path or a trapdoor;
*>   - by night hostile mobs spawn in the open, round the village.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGVILLAGE-SPAWNS.
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
 01 WS-PHASE               BINARY-LONG.
 01 WS-TICK                BINARY-LONG.
 01 WS-ONE                 BINARY-LONG VALUE 1.
 01 WS-ROW                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SEEN.
    05 WS-SEEN-ID          BINARY-LONG OCCURS 1024 TIMES.
 01 WS-DIM                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG.
 01 WS-BY                  BINARY-LONG.
 01 WS-BZ                  BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-UP                  BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-RAW                 BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-ROOFED              BINARY-LONG.
 01 WS-SIDE                BINARY-LONG.
 01 WS-STEP                BINARY-LONG.
 01 WS-FLOOR-KEY           PIC X(48).
 01 WS-ABOVE-KEY           PIC X(48).
 01 WS-SMALL               BINARY-LONG.
 01 WS-N1                  PIC -(5)9.
 01 WS-N2                  PIC -(5)9.
 01 WS-N3                  PIC -(5)9.
 01 WS-N4                  PIC -(5)9.
 01 WS-N5                  PIC -(5)9.
 01 WS-N6                  PIC -(5)9.
 01 WS-PHASE-TEXT          PIC X(5).
 01 WS-CENSUS-HOSTILE      BINARY-LONG VALUE 0.
 01 WS-CENSUS-VILLAGERS    BINARY-LONG VALUE 0.
 01 WS-DAY-HOSTILE         BINARY-LONG VALUE 0.
 01 WS-DAY-EAVES           BINARY-LONG VALUE 0.
 01 WS-NIGHT-HOSTILE       BINARY-LONG VALUE 0.
 01 WS-BAD-FLOOR           BINARY-LONG VALUE 0.
 01 WS-LX                 BINARY-LONG.
 01 WS-LZ                 BINARY-LONG.
 01 WS-LCX                BINARY-LONG.
 01 WS-LCZ                BINARY-LONG.
 01 WS-LROW               BINARY-LONG.
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
         MOVE "acc bugvillage no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "superflat" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 1 TO CS-DEFAULT-MODE
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 1 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "Flat" TO CS-NEW-WORLD-NAME
     MOVE 0 TO FS-PENDING
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-SEED TO WS-SEED
     PERFORM SCAN-STARTS
     DISPLAY "VILLAGE " FUNCTION TRIM(WS-VKEY) " chunk " WS-VX " " WS-VZ
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 1 TO PL-MODE(WS-PLAYER)
*>   The player stands in the start chunk of the village (its centre is near), and the chunks round it are generated by the stream.
     COMPUTE PL-X(WS-PLAYER) = WS-VX * 16 + 8.5
     MOVE -60 TO PL-Y(WS-PLAYER)
     COMPUTE PL-Z(WS-PLAYER) = WS-VZ * 16 + 8.5
     CALL "CHUNKS-FOLLOW" USING WS-CONN
*>   A superflat overworld is fed by the generation queue over the ticks (lane bughang), so the 5 x 5 chunks round the village start are made here, at once.
     PERFORM VARYING WS-LZ FROM -2 BY 1 UNTIL WS-LZ > 2
         PERFORM VARYING WS-LX FROM -2 BY 1 UNTIL WS-LX > 2
             COMPUTE WS-LCX = WS-VX + WS-LX
             COMPUTE WS-LCZ = WS-VZ + WS-LZ
             CALL "WORLD-CHUNK-LOAD" USING WS-DIM WS-LCX WS-LCZ WS-LROW
         END-PERFORM
     END-PERFORM
     PERFORM DRAIN
     DISPLAY "CENSUS after chunk generation"
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND WS-ROW NOT = PL-ENTITY-ROW(WS-PLAYER)
             MOVE EN-ID(WS-ROW) TO WS-SEEN-ID(WS-ROW)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0
                 DISPLAY "  ENT " FUNCTION TRIM(SM-KEY(WS-S))
                 IF SM-KEY(WS-S) = "villager"
                     ADD 1 TO WS-CENSUS-VILLAGERS
                 END-IF
                 IF SM-KIND(WS-S) = 1
                     ADD 1 TO WS-CENSUS-HOSTILE
                 END-IF
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-PHASE FROM 1 BY 1 UNTIL WS-PHASE > 2
         IF WS-PHASE = 1
             MOVE 6000 TO CW-TIME
             MOVE "day" TO WS-PHASE-TEXT
         ELSE
             MOVE 18000 TO CW-TIME
             MOVE "night" TO WS-PHASE-TEXT
         END-IF
         PERFORM VARYING WS-TICK FROM 1 BY 1 UNTIL WS-TICK > 300
             CALL "TEST-TICKS" USING WS-ONE
             PERFORM RECORD-NEW
             IF FUNCTION MOD(WS-TICK, 20) = 0
                 PERFORM DRAIN
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "acc bugvillage the village census holds villagers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-CENSUS-VILLAGERS > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acc bugvillage the village census of a plains village holds no hostile mob" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CENSUS-HOSTILE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acc bugvillage by day no hostile mob spawns in a cell with open sky beside it (under the eaves)" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-DAY-EAVES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acc bugvillage no mob spawns on a bed, carpet, farmland, path or trapdoor" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD-FLOOR TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acc bugvillage by night hostile mobs spawn in the open round the village" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-NIGHT-HOSTILE > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 DRAIN.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-DRAIN" USING WS-CONN PB-BUFFER WS-CLOSE
     CALL "PB-FREE" USING PB-BUFFER.

*> Every entity row that is new since the last look: species, cell, light, what is above and below. A hostile mob is removed once recorded.
 RECORD-NEW.
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND WS-ROW NOT = PL-ENTITY-ROW(WS-PLAYER) AND EN-ID(WS-ROW) NOT = WS-SEEN-ID(WS-ROW)
             MOVE EN-ID(WS-ROW) TO WS-SEEN-ID(WS-ROW)
             CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
             IF WS-S > 0
                 PERFORM RECORD-ONE
             END-IF
         END-IF
     END-PERFORM.

 RECORD-ONE.
     COMPUTE WS-BX = FUNCTION INTEGER(EN-X(WS-ROW))
     COMPUTE WS-BY = FUNCTION INTEGER(EN-Y(WS-ROW))
     COMPUTE WS-BZ = FUNCTION INTEGER(EN-Z(WS-ROW))
     CALL "LIGHT-RAW" USING WS-DIM WS-BX WS-BY WS-BZ WS-SKY WS-BLOCK WS-RAW
     MOVE 0 TO WS-ROOFED
     MOVE SPACES TO WS-ABOVE-KEY
     COMPUTE WS-UP = WS-BY + 1
     PERFORM UNTIL WS-UP > WS-BY + 40 OR WS-ROOFED > 0
         CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-UP WS-BZ WS-STATE
         IF WS-STATE NOT = 0
             COMPUTE WS-S = CB-S-BLOCK(WS-STATE + 1) + 1
             MOVE CB-KEY(WS-S) TO WS-ABOVE-KEY
             COMPUTE WS-ROOFED = WS-UP - WS-BY
         END-IF
         ADD 1 TO WS-UP
     END-PERFORM
     COMPUTE WS-UP = WS-BY - 1
     CALL "WORLD-GET-BLOCK" USING WS-DIM WS-BX WS-UP WS-BZ WS-STATE
     MOVE SPACES TO WS-FLOOR-KEY
     IF WS-STATE NOT = 0
         COMPUTE WS-S = CB-S-BLOCK(WS-STATE + 1) + 1
         MOVE CB-KEY(WS-S) TO WS-FLOOR-KEY
     END-IF
     MOVE 0 TO WS-SMALL
     INSPECT WS-FLOOR-KEY TALLYING WS-SMALL FOR ALL "_bed" ALL "carpet" ALL "farmland" ALL "dirt_path" ALL "trapdoor"
     IF WS-SMALL > 0
         ADD 1 TO WS-BAD-FLOOR
     END-IF
*>   the open sky beside the cell: one of the four cells next to it, at its height, is lit by the sky at 15
     MOVE 0 TO WS-SIDE
     PERFORM VARYING WS-STEP FROM 1 BY 1 UNTIL WS-STEP > 4
         MOVE WS-BX TO WS-QX
         MOVE WS-BZ TO WS-QZ
         EVALUATE WS-STEP
             WHEN 1
                 ADD 1 TO WS-QX
             WHEN 2
                 SUBTRACT 1 FROM WS-QX
             WHEN 3
                 ADD 1 TO WS-QZ
             WHEN OTHER
                 SUBTRACT 1 FROM WS-QZ
         END-EVALUATE
         CALL "LIGHT-RAW" USING WS-DIM WS-QX WS-BY WS-QZ WS-SKY WS-BLOCK WS-RAW
         IF WS-SKY = 15
             MOVE 1 TO WS-SIDE
         END-IF
     END-PERFORM
     CALL "LIGHT-RAW" USING WS-DIM WS-BX WS-BY WS-BZ WS-SKY WS-BLOCK WS-RAW
     CALL "STDMOB-INDEX" USING EN-TYPE(WS-ROW) WS-S
     MOVE WS-BX TO WS-N1
     MOVE WS-BY TO WS-N2
     MOVE WS-BZ TO WS-N3
     MOVE WS-SKY TO WS-N4
     MOVE WS-BLOCK TO WS-N5
     MOVE WS-ROOFED TO WS-N6
     DISPLAY "SPAWN " FUNCTION TRIM(WS-PHASE-TEXT) " " FUNCTION TRIM(SM-KEY(WS-S)) " cell " WS-N1 WS-N2 WS-N3
         " sky " WS-N4 " block " WS-N5 " roof-at " WS-N6 " " FUNCTION TRIM(WS-ABOVE-KEY) " floor " FUNCTION TRIM(WS-FLOOR-KEY)
         " open-side " WS-SIDE
     IF SM-KIND(WS-S) = 1 AND SM-KEY(WS-S) NOT = "slime"
         IF WS-PHASE = 1
             ADD 1 TO WS-DAY-HOSTILE
             IF WS-SIDE = 1 AND WS-SKY = 0
                 ADD 1 TO WS-DAY-EAVES
             END-IF
         ELSE
             ADD 1 TO WS-NIGHT-HOSTILE
         END-IF
     END-IF
     IF SM-KIND(WS-S) = 1
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-IF.

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
 END PROGRAM ACC-BUGVILLAGE-SPAWNS.
 COPY CORETEST.
