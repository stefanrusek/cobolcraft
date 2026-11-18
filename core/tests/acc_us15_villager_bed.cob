*> Acceptance test, a sleeping villager marks its bed (docs/protocol/19 section 22.8, 44 part 3 sections 2.1 and 2.2, 18 section 1.4 entries 6 and 14; lane 002-lane-p49q, T37004): while a villager
*> sleeps in its home bed the bed (both halves) has occupied = true, the villager's entity data holds the pose SLEEPING (entry 6, serializer POSE 20, id 2) and the sleeping position (entry 14, serializer
*> OPTIONAL_BLOCK_POS 11, the bed's head block); when it wakes the bed is free again and the entries are gone. A bed that a player or another mob sleeps in (occupied) is not a free bed.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-US15-VILLAGER-BED.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY VILSTATE.
 COPY VLMEM.
 COPY PROTO REPLACING LEADING ==PB-== BY ==BD-==.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-FY                  BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-ZF                  BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-PAIRS               PIC X(160).
 01 WS-I                   BINARY-LONG.
 01 WS-STATE               BINARY-LONG.
 01 WS-WANT                BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-POSE                BINARY-LONG.
 01 WS-POS-OK              BINARY-LONG.
 01 WS-ENTRIES             BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     CALL "VT-FLAT" USING WS-PLAYER WS-FY
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER))
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER))
     COMPUTE WS-Y = WS-FY + 1
     COMPUTE WS-X = WS-X0 + 8
     COMPUTE WS-ZF = WS-Z0 + 1
     MOVE "minecraft:red_bed" TO WS-KEY
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-Z0 WS-KEY WS-PAIRS
     MOVE "facing=north,occupied=false,part=foot" TO WS-PAIRS
     CALL "VT-PLACE" USING WS-DIM WS-X WS-Y WS-ZF WS-KEY WS-PAIRS
     CALL "VT-SCAN" USING WS-DIM WS-X0 WS-Z0
     CALL "VT-SPAWN" USING WS-DIM WS-X0 WS-Y WS-Z0 WS-V WS-S
     MOVE 13000 TO CW-TIME
     MOVE 1000 TO CW-TICKS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 800 OR VL-SLEEP(WS-S) = 1
         ADD 1 TO CW-TICKS
         CALL "STDMOB-STEP" USING WS-V
     END-PERFORM
     MOVE "acceptance US15 19§22.8 the villager went to sleep" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE VL-SLEEP(WS-S) TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "facing=north,occupied=true,part=head" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z0 WS-STATE
     MOVE "acceptance US15 19§22.8 the head of the bed is occupied while the villager sleeps" TO WS-CASE
     MOVE WS-WANT TO WS-E
     MOVE WS-STATE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "facing=north,occupied=true,part=foot" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-ZF WS-STATE
     MOVE "acceptance US15 19§22.8 and so is the foot" TO WS-CASE
     MOVE WS-WANT TO WS-E
     MOVE WS-STATE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   The entity data: pose SLEEPING and the sleeping position.
     CALL "PB-INIT" USING BD-BUFFER WS-CAPACITY
     CALL "VL-SLEEP-DATA" USING WS-V BD-BUFFER
     CALL "PB-RESET" USING BD-BUFFER
     MOVE 0 TO WS-POSE WS-POS-OK WS-ENTRIES
     PERFORM 2 TIMES
         CALL "PB-GET-METADATA-ENTRY-X" USING BD-BUFFER BD-METADATA-ENTRY-X
         IF BD-MX-INDEX = 6 AND BD-MX-SERIALIZER = 20
             ADD 1 TO WS-ENTRIES
             MOVE BD-MX-INT TO WS-POSE
         END-IF
         IF BD-MX-INDEX = 14 AND BD-MX-SERIALIZER = 11 AND BD-MX-PRESENT = 1
             ADD 1 TO WS-ENTRIES
             IF BD-MX-POS-X = WS-X AND BD-MX-POS-Y = WS-Y AND BD-MX-POS-Z = WS-Z0
                 MOVE 1 TO WS-POS-OK
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING BD-BUFFER
     MOVE "acceptance US15 18§1.4 the entity data has entry 6 (pose) and entry 14" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-ENTRIES TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 53§1 the pose is SLEEPING (id 2)" TO WS-CASE
     MOVE 2 TO WS-E
     MOVE WS-POSE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "acceptance US15 18§1.4 the sleeping position is the head block of the bed" TO WS-CASE
     MOVE 1 TO WS-E
     MOVE WS-POS-OK TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
*>   Morning: it wakes and the bed is free again.
     MOVE 2500 TO CW-TIME
     ADD 1 TO CW-TICKS
     CALL "STDMOB-STEP" USING WS-V
     MOVE "facing=north,occupied=false,part=head" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-Z0 WS-STATE
     MOVE "acceptance US15 19§22.8 when it wakes the head of the bed is free again" TO WS-CASE
     MOVE WS-WANT TO WS-E
     MOVE WS-STATE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     MOVE "facing=north,occupied=false,part=foot" TO WS-PAIRS
     CALL "BLOCKS-STATE-OF" USING WS-KEY WS-PAIRS WS-WANT
     CALL "TEST-BLOCK-AT" USING WS-X WS-Y WS-ZF WS-STATE
     MOVE "acceptance US15 19§22.8 and the foot" TO WS-CASE
     MOVE WS-WANT TO WS-E
     MOVE WS-STATE TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "PB-INIT" USING BD-BUFFER WS-CAPACITY
     CALL "VL-SLEEP-DATA" USING WS-V BD-BUFFER
     MOVE "acceptance US15 18§1.4 an awake villager has no sleeping entries" TO WS-CASE
     MOVE 0 TO WS-E
     MOVE BD-LENGTH TO WS-O
     CALL "Q3-EQ" USING WS-CASE WS-E WS-O
     CALL "PB-FREE" USING BD-BUFFER
     STOP RUN.
 END PROGRAM ACC-US15-VILLAGER-BED.
 COPY CORETEST.
 COPY MOBSPTEST.
 COPY Q3TEST.
 COPY VILLTEST.
