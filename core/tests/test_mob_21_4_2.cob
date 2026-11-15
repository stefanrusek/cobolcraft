*> Acceptance test (US15, FR-036, SC-008; docs/protocol/21 sections 4.2 and 4.4): spawn variants. A salmon is small (30), medium (50) or large (15 of 95), EN-VARIANT 1 to 3; a tropical
*> fish takes one of 22 common variants (0.9) or a random pattern of 12 and two colours of 16 (packed = pattern | base << 16 | colour << 24; EN-VARIANT is 1 + packed). The metadata
*> index 17 of the viewers' packet carries the salmon size, the packed variant and the pufferfish state (a state of 0 is the default, nothing sent).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-4-2.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY PROTO.
 COPY XORO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED VALUE 4242.
 01 WS-M                   BINARY-LONG.
 01 WS-SMALL               BINARY-LONG.
 01 WS-MEDIUM              BINARY-LONG.
 01 WS-LARGE               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-PACKED              BINARY-LONG.
 01 WS-PATTERN             BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 64.
 01 WS-DISTINCT            BINARY-LONG.
 01 WS-FIRST               BINARY-LONG.
 01 WS-COL                 BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "XORO-SEED" USING WS-SEED XR-STATE
     MOVE "N" TO TL-MODE
     MOVE PL-X(WS-PLAYER) TO WS-X
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE SPACES TO WS-KEY
     MOVE "minecraft:salmon" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE 0 TO WS-SMALL WS-MEDIUM WS-LARGE WS-BAD
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE 0 TO EN-VARIANT(WS-ROW)
         CALL "STDMOB-AQUATIC-FINALIZE" USING XR-STATE WS-ROW WS-M
         EVALUATE EN-VARIANT(WS-ROW)
             WHEN 1
                 ADD 1 TO WS-SMALL
             WHEN 2
                 ADD 1 TO WS-MEDIUM
             WHEN 3
                 ADD 1 TO WS-LARGE
             WHEN OTHER
                 ADD 1 TO WS-BAD
         END-EVALUATE
     END-PERFORM
     MOVE "acceptance US15 21§4.2 minecraft:salmon variants are small, medium and large only" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.2 salmon weights 30 : 50 : 15 (400 draws: medium most, large least, each seen)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-MEDIUM > WS-SMALL AND WS-SMALL > WS-LARGE AND WS-LARGE > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     MOVE 3 TO EN-VARIANT(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     MOVE "acceptance US15 21§4.2 a large salmon sends metadata 17 (a Set Entity Data packet)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PB-LENGTH > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
     CALL "ENTITY-REMOVE" USING WS-ROW

     MOVE SPACES TO WS-KEY
     MOVE "minecraft:tropical_fish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "STDMOB-INDEX" USING WS-TYPE WS-M
     MOVE 0 TO WS-BAD WS-DISTINCT WS-FIRST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE 0 TO EN-VARIANT(WS-ROW)
         CALL "STDMOB-AQUATIC-FINALIZE" USING XR-STATE WS-ROW WS-M
         COMPUTE WS-PACKED = EN-VARIANT(WS-ROW) - 1
         IF WS-FIRST = 0
             MOVE WS-PACKED TO WS-FIRST
         END-IF
         IF WS-PACKED NOT = WS-FIRST
             MOVE 1 TO WS-DISTINCT
         END-IF
         COMPUTE WS-HIGH = WS-PACKED / 65536
         COMPUTE WS-COL = WS-HIGH / 256
         COMPUTE WS-PATTERN = FUNCTION MOD(WS-PACKED, 65536)
         COMPUTE WS-PATTERN = WS-PATTERN / 256
         IF EN-VARIANT(WS-ROW) < 1 OR FUNCTION MOD(WS-PACKED, 256) > 1 OR WS-PATTERN > 5
                 OR FUNCTION MOD(WS-HIGH, 256) > 15 OR WS-COL > 15
             ADD 1 TO WS-BAD
         END-IF
     END-PERFORM
     MOVE "acceptance US15 21§4.4 every tropical fish variant is a valid shape, pattern and two dye colours" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     PERFORM CHECK-N
     MOVE "acceptance US15 21§4.4 the variants differ between fish" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-DISTINCT TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     MOVE "acceptance US15 21§4.4 a tropical fish sends its packed variant (metadata 17)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PB-LENGTH > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
*>   The spawn of the world (STDMOB-FINALIZE) gives both their variant.
     MOVE 0 TO EN-VARIANT(WS-ROW)
     CALL "STDMOB-FINALIZE" USING XR-STATE WS-ROW
     MOVE "acceptance US15 21§4.4 finalizeSpawn of a tropical fish chooses a variant" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF EN-VARIANT(WS-ROW) > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "ENTITY-REMOVE" USING WS-ROW

     MOVE SPACES TO WS-KEY
     MOVE "minecraft:pufferfish" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     MOVE "acceptance US15 21§4.3 a pufferfish at the default state 0 sends no metadata" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PB-LENGTH TO TL-OBSERVED-N
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
     MOVE 2 TO EN-VARIANT(WS-ROW)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW PB-BUFFER
     MOVE "acceptance US15 21§4.3 a full pufferfish (state 2) sends metadata 17" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PB-LENGTH > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
     CALL "PB-FREE" USING PB-BUFFER
     STOP RUN.
 CHECK-N.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-4-2.
 COPY CORETEST.
 COPY MOBSPTEST.
