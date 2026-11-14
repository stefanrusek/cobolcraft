*> Test infrastructure of the portal tests (lane nether; docs/protocol/39-portals.md). COPY it after the test program (after CORETEST).
*>   PT-OPEN USING skip out: 1 and nothing opened when the generated packs are missing (CC_GENERATED_DIR, default /tmp/cc-test/generated);
*>     else a standard world with the extra dimensions on is open (the Nether on its placeholder terrain: ND-PLACEHOLDER 1, NETHERDIM.cpy; a test of the real terrain moves 0 to it) (view distance 2, creative default, no hostile mobs, no weather).
*>   PT-STATE USING key (PIC X(48)), pairs (PIC X(160)), state out: BLOCKS-STATE-OF of a block key and "name=value" pairs.
*>   PT-FRAME USING dim, x, y, z of the bottom-left interior cell, axis (0 X, 1 Z), width, height: the obsidian frame (corners included)
*>     round that interior, which is cleared to air; the right direction is WEST (X) or SOUTH (Z).
*>   PT-PORTALS USING dim, x, y, z, axis, width, height, count out: the nether_portal blocks in that interior.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. PT-OPEN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY COREAPI.
 COPY NETHERDIM.
 01 WS-DIR                 PIC X(1024).
 01 WS-ENV                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 LINKAGE SECTION.
 01 L-SKIP                 BINARY-LONG.
 PROCEDURE DIVISION USING L-SKIP.
     MOVE 0 TO L-SKIP
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
         MOVE 1 TO L-SKIP
         GOBACK
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS CS-WEATHER-CHANGES
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     MOVE 1 TO ND-PLACEHOLDER
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     GOBACK.
 END PROGRAM PT-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PT-STATE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY                 PIC X(112).
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-PAIRS                PIC X(160).
 01 L-STATE                BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-PAIRS L-STATE.
     MOVE SPACES TO WS-KEY
     MOVE L-KEY TO WS-KEY
     CALL "BLOCKS-STATE-OF" USING WS-KEY L-PAIRS L-STATE
     GOBACK.
 END PROGRAM PT-STATE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PT-FRAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY-OBSIDIAN        PIC X(48) VALUE "obsidian".
 01 WS-PAIRS               PIC X(160) VALUE SPACES.
 01 WS-OBSIDIAN            BINARY-LONG.
 01 WS-AIR                 BINARY-LONG VALUE 0.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-AXIS L-W L-H.
     CALL "PT-STATE" USING WS-KEY-OBSIDIAN WS-PAIRS WS-OBSIDIAN
     MOVE -1 TO WS-RX
     MOVE 0 TO WS-RZ
     IF L-AXIS = 1
         MOVE 0 TO WS-RX
         MOVE 1 TO WS-RZ
     END-IF
     PERFORM VARYING WS-J FROM -1 BY 1 UNTIL WS-J > L-H
         PERFORM VARYING WS-I FROM -1 BY 1 UNTIL WS-I > L-W
             COMPUTE WS-X = L-X + WS-RX * WS-I
             COMPUTE WS-Y = L-Y + WS-J
             COMPUTE WS-Z = L-Z + WS-RZ * WS-I
             IF WS-I = -1 OR WS-I = L-W OR WS-J = -1 OR WS-J = L-H
                 CALL "WORLD-SET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-OBSIDIAN
             ELSE
                 CALL "WORLD-SET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-AIR
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PT-FRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PT-PORTALS.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-KEY-PORTAL          PIC X(48) VALUE "nether_portal".
 01 WS-PAIRS-X             PIC X(160) VALUE "axis=x".
 01 WS-PAIRS-Z             PIC X(160) VALUE "axis=z".
 01 WS-PORTAL-X            BINARY-LONG.
 01 WS-PORTAL-Z            BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-AXIS                 BINARY-LONG.
 01 L-W                    BINARY-LONG.
 01 L-H                    BINARY-LONG.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-X L-Y L-Z L-AXIS L-W L-H L-COUNT.
     CALL "PT-STATE" USING WS-KEY-PORTAL WS-PAIRS-X WS-PORTAL-X
     CALL "PT-STATE" USING WS-KEY-PORTAL WS-PAIRS-Z WS-PORTAL-Z
     MOVE 0 TO L-COUNT
     MOVE -1 TO WS-RX
     MOVE 0 TO WS-RZ
     IF L-AXIS = 1
         MOVE 0 TO WS-RX
         MOVE 1 TO WS-RZ
     END-IF
     PERFORM VARYING WS-J FROM 0 BY 1 UNTIL WS-J >= L-H
         PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I >= L-W
             COMPUTE WS-X = L-X + WS-RX * WS-I
             COMPUTE WS-Y = L-Y + WS-J
             COMPUTE WS-Z = L-Z + WS-RZ * WS-I
             CALL "WORLD-GET-BLOCK" USING L-DIM WS-X WS-Y WS-Z WS-STATE
             IF WS-STATE = WS-PORTAL-X OR WS-STATE = WS-PORTAL-Z
                 ADD 1 TO L-COUNT
             END-IF
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PT-PORTALS.
