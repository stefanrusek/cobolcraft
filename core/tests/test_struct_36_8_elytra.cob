*> Acceptance test of the end city ship's elytra (docs/protocol/36-structures-8-nether-and-end.md section 9.4 Elytra and 11.1 ship; core/src/struct-endcity-place.cob ENDCITY-MARKER, gen-ent.cob
*> GENT-ADD-FRAME; T26001): on the generated vanilla-data (CC_GENERATED_DIR, read only; passes as skipped without it) a city with a ship is found in the outer End; the End chunk that holds the
*> ship's Elytra marker (template cell (6,5,7), turned by the piece's rotation about its position) publishes one item frame request holding an elytra, facing the rotation of south (none south,
*> clockwise 90 west, clockwise 180 north, counterclockwise 90 east) at the marker cell's centre moved 0.46875 against the facing, and no other chunk of the ship asks for one.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-STRUCT-36-8-ELYTRA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CELLS.
 COPY GENENT.
 COPY GENBE.
 COPY STRUCTDATA.
 COPY STRUCTPIECE.
 COPY STRUCTEC.
 COPY DIMENSIONS.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-PTR                 USAGE POINTER.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(600).
 01 WS-PURPUR              BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-SET                 BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SZ                  BINARY-LONG.
 01 WS-FLAG                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-VALID               BINARY-LONG.
 01 WS-MARKER              BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-COUNT1              BINARY-LONG.
 01 WS-COUNT2              BINARY-LONG.
 01 WS-CITY                PIC X(80) VALUE "minecraft:end_city".
 01 WS-SET-KEY             PIC X(80) VALUE "minecraft:end_cities".
 01 WS-CHESTS              BINARY-LONG.
 01 WS-LAST-GB             BINARY-LONG.
 01 WS-TRIES               BINARY-LONG.
 01 WS-CITY-ROW            BINARY-LONG.
 01 WS-ED                  PIC -(9)9.
 01 WS-SHIP                BINARY-LONG.
 01 WS-MX                  BINARY-LONG.
 01 WS-MZ                  BINARY-LONG.
 01 WS-MY                  BINARY-LONG.
 01 WS-LX                  BINARY-LONG VALUE 6.
 01 WS-LZ                  BINARY-LONG VALUE 7.
 01 WS-FACE                 BINARY-LONG.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-CCX                 BINARY-LONG.
 01 WS-CCZ                 BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG.
 01 WS-HERE                BINARY-LONG.
 01 WS-TALLY               BINARY-LONG.
 01 WS-EXPX                FLOAT-LONG.
 01 WS-EXPZ                FLOAT-LONG.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-CHUNKS-DONE         BINARY-LONG.
 01 WS-CX0                 BINARY-LONG.
 01 WS-CX1                 BINARY-LONG.
 01 WS-CZ0                 BINARY-LONG.
 01 WS-CZ1                 BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
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
         MOVE "acceptance US12 36-8§8 B. End city: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE "12345" TO CS-SEED-TEXT
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE CW-SEED TO WS-SEED
     MOVE "minecraft:purpur_block" TO WS-KEY
     MOVE SPACES TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-PURPUR
     ALLOCATE 304640 CHARACTERS INITIALIZED RETURNING WS-PTR
     SET ADDRESS OF CE-CHUNK TO WS-PTR
     MOVE 0 TO WS-DIM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > DIM-TABLE-ROWS
         IF DM-GENERATOR(WS-I) = DIM-GEN-END
             MOVE WS-I TO WS-DIM
         END-IF
     END-PERFORM
     MOVE 0 TO WS-SET
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > SD-SET-COUNT
         IF SS-KEY(WS-S) = WS-SET-KEY
             MOVE WS-S TO WS-SET
         END-IF
     END-PERFORM
     MOVE "acceptance US12 36-8§8 B. End city: structure and start: the end_cities set and the End dimension are loaded" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SET > 0 AND WS-DIM > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-SET = 0 OR WS-DIM = 0
         STOP RUN
     END-IF
*>   the first valid start of the outer End whose layout has a ship piece
     MOVE 0 TO WS-FOUND WS-SHIP
     MOVE 0 TO WS-TRIES
     PERFORM VARYING WS-SX FROM 60 BY 1 UNTIL WS-SX > 400 OR WS-FOUND = 1
         PERFORM VARYING WS-SZ FROM -100 BY 1 UNTIL WS-SZ > 100 OR WS-FOUND = 1
             CALL "STRUCT-IS-CHUNK" USING WS-SET WS-SEED WS-SX WS-SZ WS-FLAG
             IF WS-FLAG = 1
                 ADD 1 TO WS-TRIES
                 CALL "ENDCITY-FIND-POINT" USING WS-SEED WS-SX WS-SZ WS-X WS-Y WS-Z WS-VALID
                 IF WS-VALID = 1 AND EC-SHIP = 1
                     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EC-COUNT
*>                       a ship whose marker cell is inside the 128 rows of a generated chunk (a city rising above y 127 is cut off there)
                         IF EP-NAME(WS-I) = "ship" AND EP-Y(WS-I) + 5 < 127
                             MOVE WS-I TO WS-SHIP
                             MOVE 1 TO WS-FOUND
                         END-IF
                     END-PERFORM
                 END-IF
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-TRIES TO WS-ED
     DISPLAY "PROBE end city with a ship after " FUNCTION TRIM(WS-ED) " candidate chunks"
     MOVE "acceptance US12 36-8§11 B. Templates, markers, loot, spawns: a city with a ship was found" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FOUND TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND = 0
         STOP RUN
     END-IF
*>   the marker cell: the template cell (6,5,7) turned about the origin by the ship's rotation, added to its position
     EVALUATE EP-ROT(WS-SHIP)
         WHEN 0
             COMPUTE WS-MX = EP-X(WS-SHIP) + WS-LX
             COMPUTE WS-MZ = EP-Z(WS-SHIP) + WS-LZ
             MOVE 3 TO WS-FACE
         WHEN 1
             COMPUTE WS-MX = EP-X(WS-SHIP) - WS-LZ
             COMPUTE WS-MZ = EP-Z(WS-SHIP) + WS-LX
             MOVE 4 TO WS-FACE
         WHEN 2
             COMPUTE WS-MX = EP-X(WS-SHIP) - WS-LX
             COMPUTE WS-MZ = EP-Z(WS-SHIP) - WS-LZ
             MOVE 2 TO WS-FACE
         WHEN OTHER
             COMPUTE WS-MX = EP-X(WS-SHIP) + WS-LZ
             COMPUTE WS-MZ = EP-Z(WS-SHIP) - WS-LX
             MOVE 5 TO WS-FACE
     END-EVALUATE
     COMPUTE WS-MY = EP-Y(WS-SHIP) + 5
     CALL "DECOR-STEP" USING WS-FACE WS-DX WS-DY WS-DZ
     COMPUTE WS-EXPX = WS-MX + 0.5 - WS-DX * 0.46875
     COMPUTE WS-EXPZ = WS-MZ + 0.5 - WS-DZ * 0.46875
     DISPLAY "PROBE ship rotation " EP-ROT(WS-SHIP) " marker cell " WS-MX " " WS-MY " " WS-MZ " facing " WS-FACE
*>   every chunk the ship's box touches: the frame request is made by the chunk of the marker only
     MOVE 0 TO WS-FRAMES WS-CHUNKS-DONE WS-HERE
     COMPUTE WS-CX0 = FUNCTION INTEGER(EP-X0(WS-SHIP) / 16)
     COMPUTE WS-CX1 = FUNCTION INTEGER(EP-X1(WS-SHIP) / 16)
     COMPUTE WS-CZ0 = FUNCTION INTEGER(EP-Z0(WS-SHIP) / 16)
     COMPUTE WS-CZ1 = FUNCTION INTEGER(EP-Z1(WS-SHIP) / 16)
     COMPUTE WS-CCX = FUNCTION INTEGER(WS-MX / 16)
     COMPUTE WS-CCZ = FUNCTION INTEGER(WS-MZ / 16)
     PERFORM VARYING WS-FX FROM WS-CX0 BY 1 UNTIL WS-FX > WS-CX1
         PERFORM VARYING WS-FZ FROM WS-CZ0 BY 1 UNTIL WS-FZ > WS-CZ1
             MOVE 0 TO GB-COUNT GE-COUNT
             MOVE LOW-VALUES TO CE-CHUNK
             CALL "END-DIM-CHUNK" USING WS-DIM WS-FX WS-FZ CE-CHUNK WS-MARKER
             ADD 1 TO WS-CHUNKS-DONE
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GE-COUNT
                 MOVE 0 TO WS-TALLY
                 INSPECT GE-NBT(WS-I)(1:GE-LEN(WS-I)) TALLYING WS-TALLY FOR ALL "minecraft:item_frame"
                 IF WS-TALLY > 0
                     ADD 1 TO WS-FRAMES
                     IF WS-FX = WS-CCX AND WS-FZ = WS-CCZ
                         ADD 1 TO WS-HERE
                         MOVE 0 TO WS-TALLY
                         INSPECT GE-NBT(WS-I)(1:GE-LEN(WS-I)) TALLYING WS-TALLY FOR ALL "minecraft:elytra"
                         COMPUTE WS-DIFF = FUNCTION ABS(GE-X(WS-I) - WS-EXPX) + FUNCTION ABS(GE-Z(WS-I) - WS-EXPZ)
                             + FUNCTION ABS(GE-Y(WS-I) - WS-MY - 0.5)
                         MOVE "acceptance US12 36-8§9.4 B. Data markers: the Elytra marker's frame holds an elytra" TO TL-CASE
                         MOVE 1 TO TL-EXPECTED-N
                         MOVE WS-TALLY TO TL-OBSERVED-N
                         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
                         MOVE "acceptance US12 36-8§9.4 B. Data markers: the frame hangs at the marker cell's centre moved 0.46875 against the rotation of south" TO TL-CASE
                         MOVE 0 TO TL-EXPECTED-N
                         COMPUTE TL-OBSERVED-N ROUNDED = WS-DIFF * 100000
                         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
                         MOVE "acceptance US12 36-8§9.4 B. Data markers: the frame faces the rotation of south (Facing byte)" TO TL-CASE
                         MOVE WS-FACE TO TL-EXPECTED-N
                         MOVE -1 TO TL-OBSERVED-N
                         PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > GE-LEN(WS-I) - 8
                             IF GE-NBT(WS-I)(WS-J:8) = X"010006" & "Facin"
                                 COMPUTE TL-OBSERVED-N = FUNCTION ORD(GE-NBT(WS-I)(WS-J + 9:1)) - 1
                             END-IF
                         END-PERFORM
                         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE "acceptance US12 36-8§9.4 B. Data markers: the chunk of the marker asks for exactly one frame" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HERE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US12 36-8§9.4 B. Data markers: no other chunk of the ship asks for a frame (one marker, one frame)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-FRAMES TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-STRUCT-36-8-ELYTRA.

 COPY NOSPAWN.
 COPY CORETEST.
