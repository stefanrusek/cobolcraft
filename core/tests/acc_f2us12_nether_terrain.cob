*> Acceptance test (US12-3 with the Nether generator wired in; docs/protocol/37-nether-1 section 6.9, 37-nether-2 to 4, 39 sections 4 and 5): a creative
*> player lights an overworld portal and steps in; she arrives in the Nether on the generated terrain: a portal made for her with six portal
*> blocks round her feet, a bedrock floor and roof under and over her column, a lava sea at y 31 and below in the chunk and none above, netherrack
*> in the open middle. Needs the generated packs (a pass without them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-F2US12-NETHER-TERRAIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY NETHERDIM.
 01 WS-SKIP                BINARY-LONG.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-Z                   BINARY-LONG.
 01 WS-FX                  BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-FZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-AXIS                BINARY-LONG VALUE 0.
 01 WS-W                   BINARY-LONG VALUE 2.
 01 WS-H                   BINARY-LONG VALUE 3.
 01 WS-FACE                BINARY-LONG VALUE 1.
 01 WS-SEQ                 BINARY-LONG VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-ITEM-KEY            PIC X(112).
 01 WS-ID                  BINARY-LONG.
 01 WS-ROW-TEXT            PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-STATE               BINARY-LONG.
 01 WS-KEY-BEDROCK         PIC X(48) VALUE "minecraft:bedrock".
 01 WS-KEY-LAVA            PIC X(48) VALUE "minecraft:lava".
 01 WS-KEY-NETHERRACK      PIC X(48) VALUE "minecraft:netherrack".
 01 WS-BEDROCK             BINARY-LONG.
 01 WS-LAVA                BINARY-LONG.
 01 WS-NETHERRACK          BINARY-LONG.
 01 WS-LAVA-LOW            BINARY-LONG.
 01 WS-LAVA-HIGH           BINARY-LONG.
 01 WS-RACK                BINARY-LONG.
 01 WS-PORTALS             BINARY-LONG.
 01 WS-CELL                BINARY-LONG.
 01 WS-A                   PIC -(9)9.
 01 WS-B                   PIC -(9)9.
 01 WS-C                   PIC -(9)9.
 01 WS-FLOOR               BINARY-LONG.
 01 WS-LX                  BINARY-LONG.
 01 WS-HX                  BINARY-LONG.
 01 WS-LZ                  BINARY-LONG.
 01 WS-HZ                  BINARY-LONG.
 01 WS-HY                  BINARY-LONG.
 01 WS-KEY-PORTAL          PIC X(48) VALUE "nether_portal".
 01 WS-PAIRS-X             PIC X(160) VALUE "axis=x".
 01 WS-PAIRS-Z             PIC X(160) VALUE "axis=z".
 01 WS-PX                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 COPY CELLS.
 PROCEDURE DIVISION.
     MOVE "T" TO TL-MODE
     CALL "PT-OPEN" USING WS-SKIP
     IF WS-SKIP = 1
         MOVE "N" TO TL-MODE
         MOVE "acceptance US12-3 nether terrain: no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     MOVE 0 TO ND-PLACEHOLDER
*>   a fixed level seed: the Nether chunk (terrain and features) is then the same on every run
     MOVE 12345 TO CW-SEED
     CALL "GEN-BLOCK-STATE" USING WS-KEY-BEDROCK WS-BEDROCK
     CALL "GEN-BLOCK-STATE" USING WS-KEY-LAVA WS-LAVA
     CALL "GEN-BLOCK-STATE" USING WS-KEY-NETHERRACK WS-NETHERRACK
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE
     MOVE CN-PLAYER(WS-ALICE) TO WS-ROW
     MOVE 1 TO PL-MODE(WS-ROW)

     MOVE DIM-STANDARD-OVERWORLD TO WS-DIM
     MOVE 10 TO WS-X MOVE 100 TO WS-Y MOVE 10 TO WS-Z
     CALL "PT-FRAME" USING WS-DIM WS-X WS-Y WS-Z WS-AXIS WS-W WS-H
     MOVE "flint_and_steel" TO WS-ITEM-KEY
     CALL "CONTENT-ITEM-BY-KEY" USING WS-ITEM-KEY WS-ID WS-ROW-TEXT WS-STATUS
     MOVE WS-ID TO PL-SLOT-ITEM(WS-ROW, 5)
     MOVE 1 TO PL-SLOT-COUNT(WS-ROW, 5)
     MOVE 0 TO PL-SLOT-VAR(WS-ROW, 5)
     MOVE 4 TO WS-SLOT
     CALL "TEST-HELD" USING WS-ALICE WS-SLOT
     MOVE 9 TO WS-X MOVE 99 TO WS-Y
     ADD 1 TO WS-SEQ
     CALL "TEST-USE-ON" USING WS-ALICE WS-X WS-Y WS-Z WS-FACE WS-SEQ
     MOVE 10.0 TO PL-X(WS-ROW)
     MOVE 100.0 TO PL-Y(WS-ROW)
     MOVE 10.5 TO PL-Z(WS-ROW)
     MOVE 0 TO PL-YAW(WS-ROW)
     CALL "TEST-TICKS" USING WS-TWO

     MOVE "acceptance US12-3 nether terrain: she is in the nether (row 4) after two ticks" TO TL-CASE
     MOVE PL-DIM(WS-ROW) TO WS-A
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "4" TO TL-EXPECTED
     PERFORM CHECK

     COMPUTE WS-FX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-FY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-FZ = FUNCTION INTEGER(PL-Z(WS-ROW))
*>   The portal made for her: six portal blocks within two blocks of her feet.
     MOVE 0 TO WS-PORTALS
     COMPUTE WS-LX = WS-FX - 2
     COMPUTE WS-HX = WS-FX + 2
     COMPUTE WS-LZ = WS-FZ - 2
     COMPUTE WS-HZ = WS-FZ + 2
     COMPUTE WS-HY = WS-FY + 3
     PERFORM VARYING WS-Y FROM WS-FY BY 1 UNTIL WS-Y > WS-HY
         PERFORM VARYING WS-X FROM WS-LX BY 1 UNTIL WS-X > WS-HX
             PERFORM VARYING WS-Z FROM WS-LZ BY 1 UNTIL WS-Z > WS-HZ
                 CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-STATE
                 PERFORM COUNT-PORTAL
             END-PERFORM
         END-PERFORM
     END-PERFORM
     MOVE WS-PORTALS TO WS-A
     MOVE "acceptance US12-3 nether terrain: six portal blocks stand round her feet on the generated terrain" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     MOVE FUNCTION TRIM(WS-A) TO TL-OBSERVED
     MOVE "6" TO TL-EXPECTED
     PERFORM CHECK

*>   Her column: bedrock at y 0 and y 127, the portal frame above the generated terrain (obsidian under her feet).
     MOVE WS-FX TO WS-X
     MOVE WS-FZ TO WS-Z
     MOVE 0 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-A
     IF WS-STATE = WS-BEDROCK
         MOVE 1 TO WS-A
     END-IF
     MOVE 127 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-STATE
     MOVE 0 TO WS-B
     IF WS-STATE = WS-BEDROCK
         MOVE 1 TO WS-B
     END-IF
     MOVE 128 TO WS-Y
     CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-X WS-Y WS-Z WS-STATE
     MOVE WS-STATE TO WS-C
     MOVE "acceptance US12-3 nether terrain: bedrock at y 0 and y 127 of her column and nothing at y 128" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 1 0" TO TL-EXPECTED
     PERFORM CHECK

*>   Her chunk: a lava sea at y 1 to 31 (some lava), none above, netherrack in the middle.
     COMPUTE WS-CX = (WS-FX - FUNCTION MOD(WS-FX, 16)) / 16
     COMPUTE WS-CZ = (WS-FZ - FUNCTION MOD(WS-FZ, 16)) / 16
     MOVE 0 TO WS-LAVA-LOW WS-LAVA-HIGH WS-RACK
     PERFORM VARYING WS-Y FROM 1 BY 1 UNTIL WS-Y > 126
         PERFORM VARYING WS-Z FROM 0 BY 1 UNTIL WS-Z > 15
             PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
                 COMPUTE WS-FLOOR = WS-CX * 16 + WS-X
                 COMPUTE WS-CELL = WS-CZ * 16 + WS-Z
                 CALL "WORLD-GET-BLOCK" USING DIM-STANDARD-NETHER WS-FLOOR WS-Y WS-CELL WS-STATE
                 EVALUATE TRUE
                     WHEN WS-STATE = WS-LAVA AND WS-Y <= 31
                         ADD 1 TO WS-LAVA-LOW
                     WHEN WS-STATE = WS-LAVA
                         ADD 1 TO WS-LAVA-HIGH
                     WHEN WS-STATE = WS-NETHERRACK AND WS-Y > 32 AND WS-Y < 100
                         ADD 1 TO WS-RACK
                 END-EVALUATE
             END-PERFORM
         END-PERFORM
     END-PERFORM
     IF WS-LAVA-LOW > 0
         MOVE 1 TO WS-LAVA-LOW
     END-IF
     IF WS-RACK > 100
         MOVE 1 TO WS-RACK
     END-IF
*>   Above y 31 only the lava springs of the features (35 and 37-5: a few cells of the chunk, in the netherrack) are lava: under 40 cells of the chunk.
     IF WS-LAVA-HIGH < 40
         MOVE 0 TO WS-LAVA-HIGH
     END-IF
     MOVE WS-LAVA-LOW TO WS-A
     MOVE WS-LAVA-HIGH TO WS-B
     MOVE WS-RACK TO WS-C
     MOVE "acceptance US12-3 nether terrain: her chunk holds lava at y <= 31, none above but the few lava springs of the features, and netherrack in the open middle" TO TL-CASE
     MOVE SPACES TO TL-OBSERVED
     STRING FUNCTION TRIM(WS-A) " " FUNCTION TRIM(WS-B) " " FUNCTION TRIM(WS-C) DELIMITED BY SIZE INTO TL-OBSERVED
     MOVE "1 0 1" TO TL-EXPECTED
     PERFORM CHECK
     STOP RUN.

 COUNT-PORTAL.
     CALL "PT-STATE" USING WS-KEY-PORTAL WS-PAIRS-X WS-PX
     CALL "PT-STATE" USING WS-KEY-PORTAL WS-PAIRS-Z WS-PZ
     IF WS-STATE = WS-PX OR WS-STATE = WS-PZ
         ADD 1 TO WS-PORTALS
     END-IF.

 CHECK.
     MOVE "T" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-F2US12-NETHER-TERRAIN.

 COPY CORETEST.
 COPY PORTALTEST.
