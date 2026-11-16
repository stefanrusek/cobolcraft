*> Test of the data-driven end_podium type (registry id 14; docs/protocol/35-worldgen-features-7-nether-end-misc.md section 10.3; core/src/feat-end.cob) and of the block entity request of
*> an end_gateway feature with an exit (10.4: setExitPosition(exit, exact); core/src/feat-end.cob, gen-be.cob kind 3). The podium features compile (active absent, true; a non-boolean active
*> is unsupported); for active and inactive the shadow model written from the 10.3 table (inner distSqr < 6.25, outer < 12.25, bedrock / end stone / portal or air / rim, air above, the four-high
*> bedrock pillar, the four torches) predicts every cell of the window of the chunk. A gateway feature with an exit asks for a kind 3 entity request at its centre carrying the exit and the exact
*> flag; one without a usable exit (a two-element position) is unsupported.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-FEAT-END-PODIUM.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CBLOCKS.
 COPY CELLS.
 COPY FEATDATA.
 COPY FEATLEVEL.
 COPY GENBE.
 COPY XORO.
 01 WS-DIR                 PIC X(1100) VALUE "core/tests/fixtures/endfeat".
 01 WS-PTR                 USAGE POINTER.
 01 WS-AREA                PIC X(304640) BASED.
 01 WS-X0 BINARY-LONG.
 01 WS-X1 BINARY-LONG.
 01 WS-Y0 BINARY-LONG.
 01 WS-Y1 BINARY-LONG.
 01 WS-Z0 BINARY-LONG.
 01 WS-Z1 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-FT                  BINARY-LONG.
 01 WS-RESULT              BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-MIN                 BINARY-LONG VALUE 0.
 01 WS-HEIGHT              BINARY-LONG VALUE 256.
 01 WS-SEA                 BINARY-LONG VALUE 0.
 01 WS-FLAGS               BINARY-LONG VALUE 2.
 01 WS-OK                  BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 5.
 01 WS-KEY                 PIC X(112).
 01 WS-NAME                PIC X(48).
 01 WS-FTKEY               PIC X(80).
 01 WS-PAIRS               PIC X(160).
 01 WS-CASE                PIC X(200).
 01 WS-OBS                 BINARY-LONG.
 01 WS-EXP                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ACTIVE              BINARY-LONG.
 01 WS-QX                  BINARY-LONG.
 01 WS-QY                  BINARY-LONG.
 01 WS-QZ                  BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-D2                  BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-CLASS               BINARY-LONG.
 01 WS-EXPCLASS            BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-S-ENDSTONE          BINARY-LONG.
 01 WS-B-BEDROCK           BINARY-LONG.
 01 WS-B-ENDSTONE          BINARY-LONG.
 01 WS-B-PORTAL            BINARY-LONG.
 01 WS-B-TORCH             BINARY-LONG.
 01 WS-B-AIR               BINARY-LONG.
 01 WS-NUMS.
    05 WS-NUM              PIC S9(9) SIGN LEADING SEPARATE OCCURS 3 TIMES.
 01 WS-CASETXT             PIC 9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE "content/tests/fixtures/std" TO CS-GENERATED-DIR
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     ALLOCATE CE-CHUNK-BYTES CHARACTERS INITIALIZED RETURNING WS-PTR
     CALL "FD-SET-DIR" USING WS-DIR
     CALL "FD-RESET"
     MOVE "end_stone" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-ENDSTONE
     MOVE CB-DEFAULT-STATE(WS-WANT) TO WS-S-ENDSTONE
     MOVE "bedrock" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-BEDROCK
     MOVE "end_portal" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-PORTAL
     MOVE "wall_torch" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-TORCH
     MOVE "air" TO WS-KEY
     PERFORM WANT-BLOCK
     MOVE WS-WANT TO WS-B-AIR

*>   compile
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1
                 MOVE "minecraft:podium_off" TO WS-FTKEY
                 MOVE 14 TO WS-EXP
                 MOVE "an end_podium without active" TO WS-NAME
             WHEN 2
                 MOVE "minecraft:podium_on" TO WS-FTKEY
                 MOVE 14 TO WS-EXP
                 MOVE "an active end_podium" TO WS-NAME
             WHEN 3
                 MOVE "minecraft:podium_bad" TO WS-FTKEY
                 MOVE -1 TO WS-EXP
                 MOVE "a podium with a string active (unsupported)" TO WS-NAME
             WHEN 4
                 MOVE "minecraft:gate_exit" TO WS-FTKEY
                 MOVE 11 TO WS-EXP
                 MOVE "an end_gateway with a three-element exit" TO WS-NAME
             WHEN OTHER
                 MOVE "minecraft:gate_badexit" TO WS-FTKEY
                 MOVE -1 TO WS-EXP
                 MOVE "a gateway with a 2-element exit (unsupported)" TO WS-NAME
         END-EVALUATE
         CALL "FD-GET-FT" USING WS-FTKEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         MOVE SPACES TO WS-CASE
         STRING "35-7§10.3-4: " FUNCTION TRIM(WS-NAME) " compiles to its type" DELIMITED BY SIZE INTO WS-CASE
         MOVE FT-TYPE(WS-FT) TO WS-OBS
         PERFORM ASSERT-N
     END-PERFORM

*>   the podium against the model: inactive then active, the origin (24, 62, 40)
     PERFORM VARYING WS-ACTIVE FROM 0 BY 1 UNTIL WS-ACTIVE > 1
         IF WS-ACTIVE = 0
             MOVE "minecraft:podium_off" TO WS-FTKEY
         ELSE
             MOVE "minecraft:podium_on" TO WS-FTKEY
         END-IF
         CALL "FD-GET-FT" USING WS-FTKEY WS-FT
         CALL "FD-ENSURE-FT" USING WS-FT
         PERFORM NEW-WORLD
         MOVE 24 TO WS-PX
         MOVE 62 TO WS-PY
         MOVE 40 TO WS-PZ
         CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-PX WS-PY WS-PZ WS-RESULT
         MOVE 0 TO WS-BAD
         PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
             PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
                 PERFORM VARYING WS-QY FROM 0 BY 1 UNTIL WS-QY > 110
                     PERFORM MODEL-CLASS
                     CALL "FL-GET-STATE" USING WS-QX WS-QY WS-QZ WS-STATE
                     CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
                     EVALUATE TRUE
                         WHEN WS-BLOCK = WS-B-BEDROCK
                             MOVE 1 TO WS-CLASS
                         WHEN WS-BLOCK = WS-B-ENDSTONE
                             MOVE 2 TO WS-CLASS
                         WHEN WS-BLOCK = WS-B-PORTAL
                             MOVE 3 TO WS-CLASS
                         WHEN WS-BLOCK = WS-B-TORCH
                             MOVE 4 TO WS-CLASS
                         WHEN OTHER
                             MOVE 0 TO WS-CLASS
                     END-EVALUATE
                     IF WS-CLASS NOT = WS-EXPCLASS
                         ADD 1 TO WS-BAD
                     END-IF
                 END-PERFORM
             END-PERFORM
         END-PERFORM
         MOVE SPACES TO WS-CASE
         MOVE WS-ACTIVE TO WS-CASETXT
         STRING "35-7§10.3: active " WS-CASETXT " every cell of the window agrees with the model" DELIMITED BY SIZE INTO WS-CASE
         MOVE WS-BAD TO WS-OBS
         MOVE 0 TO WS-EXP
         PERFORM ASSERT-N
         MOVE SPACES TO WS-CASE
         STRING "35-7§10.3: active " WS-CASETXT " the portal layer holds the portal only when active (centre cell above the pillar base is bedrock)" DELIMITED BY SIZE INTO WS-CASE
         MOVE 24 TO WS-X
         MOVE 62 TO WS-Y
         MOVE 41 TO WS-Z
         CALL "FL-GET-STATE" USING WS-X WS-Y WS-Z WS-STATE
         CALL "FL-BLOCK-OF" USING WS-STATE WS-BLOCK
         MOVE 0 TO WS-OBS
         IF WS-BLOCK = WS-B-PORTAL
             MOVE 1 TO WS-OBS
         END-IF
         MOVE WS-ACTIVE TO WS-EXP
         PERFORM ASSERT-N
     END-PERFORM

*>   the gateway with an exit asks for a kind 3 request
     MOVE 0 TO GBL-COUNT GBL-LOST
     MOVE "minecraft:gate_exit" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     PERFORM NEW-WORLD
     MOVE 24 TO WS-PX
     MOVE 70 TO WS-PY
     MOVE 40 TO WS-PZ
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-PX WS-PY WS-PZ WS-RESULT
     MOVE "35-7§10.4: the gateway feature with an exit asks for one entity request" TO WS-CASE
     MOVE GBL-COUNT TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE "35-7§10.4: the request is of kind 3 at the gateway block" TO WS-CASE
     COMPUTE WS-OBS = GBL-KIND(1) * 1000000 + (GBL-X(1) - 24) * 10000 + (GBL-Y(1) - 70) * 100 + (GBL-Z(1) - 40)
     MOVE 3000000 TO WS-EXP
     PERFORM ASSERT-N
     MOVE GBL-TEXT(1) TO WS-NUMS
     MOVE "35-7§10.4: the request carries the exit position (5, 60, -7)" TO WS-CASE
     COMPUTE WS-OBS = (WS-NUM(1) + 100) * 1000000 + (WS-NUM(2) + 100) * 1000 + (WS-NUM(3) + 100)
     COMPUTE WS-EXP = 105 * 1000000 + 160 * 1000 + 93
     PERFORM ASSERT-N
     MOVE "35-7§10.4: the request flags are exit present and exact false" TO WS-CASE
     MOVE GBL-SEED(1) TO WS-OBS
     MOVE 1 TO WS-EXP
     PERFORM ASSERT-N
     MOVE 0 TO GBL-COUNT GBL-LOST
     MOVE "minecraft:gate_t" TO WS-FTKEY
     CALL "FD-GET-FT" USING WS-FTKEY WS-FT
     CALL "FD-ENSURE-FT" USING WS-FT
     PERFORM NEW-WORLD
     CALL "FR-PLACE-FT" USING XR-STATE WS-FT WS-PX WS-PY WS-PZ WS-RESULT
     MOVE "35-7§10.4: the return gateway (exit (100, 50, 0), exact) flags are exit present and exact (3)" TO WS-CASE
     MOVE GBL-SEED(1) TO WS-OBS
     MOVE 3 TO WS-EXP
     PERFORM ASSERT-N
     STOP RUN
     .
*> MODEL-CLASS: the class of the cell (WS-QX, WS-QY, WS-QZ) after the podium at (24, 62, 40): 0 untouched (end stone to y 61 and air above, class by the world fill: 2 below 62 else 0), 1 bedrock,
*> 2 end stone, 3 portal, 4 torch
 MODEL-CLASS.
     COMPUTE WS-DX = WS-QX - 24
     COMPUTE WS-DY = WS-QY - 62
     COMPUTE WS-DZ = WS-QZ - 40
     COMPUTE WS-D2 = WS-DX * WS-DX + WS-DY * WS-DY + WS-DZ * WS-DZ
     IF WS-QY <= 61
         MOVE 2 TO WS-EXPCLASS
     ELSE
         MOVE 0 TO WS-EXPCLASS
     END-IF
     IF WS-DX >= -4 AND WS-DX <= 4 AND WS-DZ >= -4 AND WS-DZ <= 4 AND WS-DY >= -1 AND WS-DY <= 32
         IF WS-D2 * 4 < 25
             EVALUATE TRUE
                 WHEN WS-DY < 0
                     MOVE 1 TO WS-EXPCLASS
                 WHEN WS-DY = 0 AND WS-ACTIVE = 1
                     MOVE 3 TO WS-EXPCLASS
                 WHEN WS-DY = 0
                     MOVE 0 TO WS-EXPCLASS
                 WHEN OTHER
                     MOVE 0 TO WS-EXPCLASS
             END-EVALUATE
         ELSE
             IF WS-D2 * 4 < 49
                 EVALUATE TRUE
                     WHEN WS-DY < 0
                         MOVE 2 TO WS-EXPCLASS
                     WHEN WS-DY = 0
                         MOVE 1 TO WS-EXPCLASS
                     WHEN OTHER
                         MOVE 0 TO WS-EXPCLASS
                 END-EVALUATE
             END-IF
         END-IF
     END-IF
*>   the pillar and the four torches
     IF WS-DX = 0 AND WS-DZ = 0 AND WS-DY >= 0 AND WS-DY <= 3
         MOVE 1 TO WS-EXPCLASS
     END-IF
     IF WS-DY = 2
         IF (WS-DX = 0 AND (WS-DZ = -1 OR WS-DZ = 1)) OR (WS-DZ = 0 AND (WS-DX = -1 OR WS-DX = 1))
             MOVE 4 TO WS-EXPCLASS
         END-IF
     END-IF
     .
*> NEW-WORLD: the chunk (1, 2) of the End level: end stone up to y 61, air above
 NEW-WORLD.
     SET ADDRESS OF WS-AREA TO WS-PTR
     MOVE LOW-VALUES TO WS-AREA
     CALL "FL-OPEN" USING WS-PTR WS-CX WS-CZ WS-MIN WS-HEIGHT WS-SEA
     PERFORM VARYING WS-QX FROM 16 BY 1 UNTIL WS-QX > 31
         PERFORM VARYING WS-QZ FROM 32 BY 1 UNTIL WS-QZ > 47
             PERFORM VARYING WS-QY FROM 0 BY 1 UNTIL WS-QY > 61
                 CALL "FL-SET-STATE" USING WS-QX WS-QY WS-QZ WS-S-ENDSTONE WS-FLAGS WS-OK
             END-PERFORM
         END-PERFORM
     END-PERFORM
     CALL "WGR-SET-SEED" USING XR-STATE WS-SEED
     .
 COPY FWTEST.
 END PROGRAM TEST-FEAT-END-PODIUM.
 COPY CORETEST.
