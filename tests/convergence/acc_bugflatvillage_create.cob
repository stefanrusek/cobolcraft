*> Convergence acceptance test of the operator report "superflat has no villages now" (try14 play; bug lane bugflatvillage; docs/protocol/56-superflat-world.md
*> sections 2.6 and 4.7, 36-1 section 11): a new superflat world made from the create-world screen with the seed field empty (the core draws a random seed, 11 section 12.1) and the
*> default preset `flat`, through the client's single-player host, from the generated vanilla packs (CC_GENERATED_DIR; a pass without them). Expected: the structure code of the open
*> world finds a village start within 24 chunks of the origin; /locate structure #minecraft:village answers with a position; and when the Player is taken to that village
*> (/tp) the client's replica holds structure blocks above the grass floor there (the pieces of the village reached the client).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGFLATVILLAGE-CREATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CONVH.
 COPY CLCONST.
 01 WS-DIR                 PIC X(64) VALUE "build/conv-bugflatvillage-create".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 32.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-FOLDER              PIC X(80) VALUE "FlatVillage".
 01 WS-FOLDER-LENGTH       BINARY-LONG VALUE 11.
 01 WS-MODE                BINARY-LONG VALUE 1.
 01 WS-ALICE               BINARY-LONG.
 01 WS-JOINED              BINARY-LONG.
 01 WS-DIR-ENV             PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-SCREEN              BINARY-LONG VALUE SCR-CREATE-WORLD.
 01 WS-LINE                PIC X(64).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE.
 01 WS-VILLAGES            BINARY-LONG.
 01 WS-GEN                 BINARY-LONG.
 01 WS-GATE                BINARY-LONG.
 01 WS-VX                  BINARY-LONG.
 01 WS-VZ                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-SKY                 BINARY-LONG.
 01 WS-BLOCK               BINARY-LONG.
 01 WS-OTHER               BINARY-LONG.
 01 WS-ROUND               BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG VALUE 20.
 01 WS-PX                  PIC -(7)9.
 01 WS-PZ                  PIC -(7)9.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     MOVE SPACES TO WS-DIR-ENV
     ACCEPT WS-DIR-ENV FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-DIR-ENV = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-DIR-ENV
     END-IF
     MOVE SPACES TO WS-FILE
     STRING FUNCTION TRIM(WS-DIR-ENV TRAILING) "/vanilla-data/pack.mcmeta" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-FILE-INFO
     IF RETURN-CODE NOT = 0
         MOVE "N" TO TL-MODE
         MOVE "acceptance bugflatvillage: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "CV-INIT" USING CONVH WS-DIR WS-DIR-LENGTH
     CALL "CV-CLIENT-ADD" USING CONVH WS-NAME WS-NAME-LENGTH WS-ALICE
     SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
     MOVE SPACES TO CL-GENERATED-DIR
     MOVE WS-DIR-ENV TO CL-GENERATED-DIR
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-DIR-ENV TRAILING)) TO CL-GENERATED-DIR-LENGTH
     CALL "PACKS-RELOAD" USING CLIENT-STATE
*>   the create-world screen with the superflat type and no seed text (random seed), the default preset
     CALL "SCREEN-OPEN" USING CLIENT-STATE WS-SCREEN
     MOVE CL-TYPE-SUPERFLAT TO SP-CREATE-TYPE
     CALL "CV-HOST-OPEN" USING CONVH WS-ALICE WS-FOLDER WS-FOLDER-LENGTH WS-MODE
     CALL "CV-UNTIL-PLAY" USING CONVH WS-ALICE WS-JOINED
     CALL "BUGFLATVILLAGE-SCAN" USING WS-SEED WS-VX WS-VZ WS-VILLAGES WS-GEN WS-GATE

     MOVE "acceptance bugflatvillage: given a new superflat world of a random seed when the structure starts of 49 x 49 chunks are listed then a village start is among them" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-VILLAGES > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "T" TO TL-MODE

     MOVE "/locate structure #minecraft:village" TO WS-LINE
     MOVE 37 TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 10 TO WS-ROUND
     CALL "CV-STEPS" USING CONVH WS-ROUND
     MOVE WS-VX TO WS-PX
     MOVE WS-VZ TO WS-PZ
     DISPLAY "SEED " WS-SEED " nearest village start chunk " WS-PX " " WS-PZ " gen " WS-GEN " gate " WS-GATE

*>   Taken to the village: the replica holds structure blocks above the grass of the floor (y -60 and up) near its start chunk.
     COMPUTE WS-X = WS-VX * 16 + 8
     COMPUTE WS-Z = WS-VZ * 16 + 8
     MOVE SPACES TO WS-LINE
     MOVE WS-X TO WS-PX
     MOVE WS-Z TO WS-PZ
     STRING "/tp Alice " FUNCTION TRIM(WS-PX) " -58 " FUNCTION TRIM(WS-PZ) DELIMITED BY SIZE INTO WS-LINE
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-LINE)) TO WS-LINE-LENGTH
     CALL "CV-SAY" USING CONVH WS-ALICE WS-LINE WS-LINE-LENGTH
     MOVE 0 TO WS-OTHER
     PERFORM VARYING WS-ROUND FROM 1 BY 1 UNTIL WS-ROUND > 40 OR WS-OTHER > 0
         CALL "CV-STEPS" USING CONVH WS-FRAMES
         SET ADDRESS OF CLIENT-STATE TO CV-ADDR(WS-ALICE)
         PERFORM COUNT-REPLICA
     END-PERFORM
     MOVE "acceptance bugflatvillage: given the Player taken to the nearest village of a new superflat world then the client replica holds structure blocks above the grass there" TO TL-CASE
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-OTHER > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> WS-OTHER: the cells above the grass (y -60 to -40) of the 48 x 48 blocks round the village start chunk that the client replica holds and that are not air.
 COUNT-REPLICA.
     MOVE 0 TO WS-OTHER
     PERFORM VARYING WS-Y FROM -60 BY 1 UNTIL WS-Y > -40
         COMPUTE WS-X = WS-VX * 16 - 16
         PERFORM UNTIL WS-X >= WS-VX * 16 + 32
             COMPUTE WS-Z = WS-VZ * 16 - 16
             PERFORM UNTIL WS-Z >= WS-VZ * 16 + 32
                 CALL "WORLD-CELL" USING CLIENT-STATE WS-X WS-Y WS-Z WS-STATE WS-SKY WS-BLOCK
                 IF WS-STATE NOT = 0
                     ADD 1 TO WS-OTHER
                 END-IF
                 ADD 1 TO WS-Z
             END-PERFORM
             ADD 1 TO WS-X
         END-PERFORM
     END-PERFORM.
 END PROGRAM ACC-BUGFLATVILLAGE-CREATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BUGFLATVILLAGE-SCAN.
*> USING seed out (the open world's), village chunk x, z out (the one nearest the origin of the 49 x 49 chunks round it), villages out, generate-structures flag out, gate size out.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY STRUCTDATA.
 COPY FLATSET.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BEST                BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-KEY80               PIC X(80).
 LINKAGE SECTION.
 01 L-SEED                 BINARY-DOUBLE.
 01 L-VX                   BINARY-LONG.
 01 L-VZ                   BINARY-LONG.
 01 L-VILLAGES             BINARY-LONG.
 01 L-GEN                  BINARY-LONG.
 01 L-GATE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SEED L-VX L-VZ L-VILLAGES L-GEN L-GATE.
     MOVE CW-SEED TO L-SEED
     MOVE FS-GEN-STRUCT TO L-GEN
     MOVE SD-GATE-COUNT TO L-GATE
     MOVE 0 TO L-VILLAGES L-VX L-VZ
     MOVE 999999 TO WS-BEST
     IF SD-POSS-DONE = 0
         CALL "STRUCT-POSSIBLE-BUILD"
     END-IF
     PERFORM VARYING WS-CX FROM -24 BY 1 UNTIL WS-CX > 24
         PERFORM VARYING WS-CZ FROM -24 BY 1 UNTIL WS-CZ > 24
             CALL "STRUCT-CHUNK-STARTS" USING L-SEED WS-CX WS-CZ WS-COUNT
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-COUNT
                 MOVE SDT-KEY(SC-STRUCT(WS-J)) TO WS-KEY80
                 IF WS-KEY80(1:18) = "minecraft:village_"
                     ADD 1 TO L-VILLAGES
                     COMPUTE WS-D = WS-CX * WS-CX + WS-CZ * WS-CZ
                     IF WS-D < WS-BEST
                         MOVE WS-D TO WS-BEST
                         MOVE WS-CX TO L-VX
                         MOVE WS-CZ TO L-VZ
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM BUGFLATVILLAGE-SCAN.
