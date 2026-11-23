*> Acceptance test, the villager head shake (docs/protocol/19 section 22.4 mobInteract: a baby, or an adult main-hand click with no offers, sets the unhappy counter to 40; entity
*> data index 18 INT counts down, 19 section 22 metadata table; wrap lane C, T59603 and T42704). Through the real Interact packet (0x1A): an unemployed adult and a baby get the
*> head shake and no window, a villager with offers opens its window and does not shake, a sleeping villager ignores the click. The counter reaches the viewers as entity data
*> index 18 (MOB-DATA-BUILD, and Set Entity Data every tick while it counts down, with the final 0), 1 per tick.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-WRAPC-VILLAGER-UNHAPPY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY VILSTATE.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MQ-==.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-PX                  BINARY-LONG.
 01 WS-PY                  BINARY-LONG.
 01 WS-PZ                  BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-S1                  BINARY-LONG.
 01 WS-S2                  BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-HAND0               BINARY-LONG VALUE 0.
 01 WS-SNEAK0              BINARY-LONG VALUE 0.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-ROWKEY              BINARY-LONG.
 01 WS-F1                  BINARY-LONG.
 01 WS-IDS                 PIC X(1024).
 01 WS-SPACED              PIC X(1030).
 01 WS-N60                 PIC 9.
 01 WS-N92                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-RUN                 BINARY-LONG.
 01 WS-TOKEN               PIC X(16).
 01 WS-TICK                BINARY-LONG.
 01 WS-E1                  PIC -(9)9.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE 3000 TO CW-TIME
     MOVE "Alice" TO WS-NAME
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     CALL "TEST-STANDARD-TABLES"
     MOVE CN-PLAYER(WS-CONN) TO WS-ROW
     MOVE PL-DIM(WS-ROW) TO WS-DIM
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     COMPUTE WS-PX = FUNCTION INTEGER(PL-X(WS-ROW))
     COMPUTE WS-PY = FUNCTION INTEGER(PL-Y(WS-ROW))
     COMPUTE WS-PZ = FUNCTION INTEGER(PL-Z(WS-ROW))
*>   An unemployed adult in front of the player and a farmer beside it (the profession set directly; xp 1 keeps ResetProfession away).
     COMPUTE WS-X = WS-PX + 0.5
     MOVE WS-PY TO WS-Y
     COMPUTE WS-Z = WS-PZ + 1.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V1
     CALL "VL-FIND" USING EN-ID(WS-V1) WS-NO WS-S1
     COMPUTE WS-X = WS-PX - 0.5
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-V2
     CALL "VL-FIND" USING EN-ID(WS-V2) WS-NO WS-S2
     MOVE "farmer" TO VL-PROF(WS-S2)
     MOVE 1 TO VL-XP(WS-S2)
     MOVE "T" TO TL-MODE
     MOVE 1 TO WS-TICK
     CALL "TEST-TICKS" USING WS-TICK
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
*>   Nothing has shaken its head yet.
     MOVE WS-V1 TO WS-ROWKEY
     PERFORM FIND-DATA
     MOVE "N" TO TL-MODE
     MOVE "acceptance 19§22.4 a villager nobody refused has no unhappy counter in its data" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-F1 TO TL-OBSERVED-N
     PERFORM CHECK
*>   The adult without a profession (no offers) is clicked: no window, the head shake starts at 40.
     MOVE "T" TO TL-MODE
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance 19§22.4 an adult villager with no offers opens no window" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     MOVE WS-N60 TO TL-OBSERVED
     PERFORM CHECK
     MOVE "N" TO TL-MODE
     MOVE WS-V1 TO WS-ROWKEY
     PERFORM FIND-DATA
     MOVE "acceptance 19§22.4 the refusal sets the unhappy counter (entity data 18) to 40" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE WS-F1 TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "T" TO TL-MODE
     MOVE "acceptance 19§22.4 the click sends the head shake to the viewers (Set Entity Data)" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     PERFORM COUNT-DATA
     PERFORM CHECK
*>   It counts down one a tick and every tick is sent to the viewers.
     MOVE 5 TO WS-TICK
     CALL "TEST-TICKS" USING WS-TICK
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "N" TO TL-MODE
     MOVE WS-V1 TO WS-ROWKEY
     PERFORM FIND-DATA
     MOVE "acceptance 19§22.4 the unhappy counter counts down 1 per tick (5 ticks: 35)" TO TL-CASE
     MOVE 35 TO TL-EXPECTED-N
     MOVE WS-F1 TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "T" TO TL-MODE
     MOVE "acceptance 19§22.4 the counter's change reaches the viewers every tick (5 Set Entity Data)" TO TL-CASE
     MOVE "5" TO TL-EXPECTED
     PERFORM COUNT-DATA
     PERFORM CHECK
*>   Run out: 35 more ticks; the last of them sends the 0 (data 18 = 0) and then nothing more is sent.
     MOVE 35 TO WS-TICK
     CALL "TEST-TICKS" USING WS-TICK
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "N" TO TL-MODE
     MOVE WS-V1 TO WS-ROWKEY
     PERFORM FIND-DATA
     MOVE "acceptance 19§22.4 after 40 ticks the counter is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-F1 TO TL-OBSERVED-N
     PERFORM CHECK
     MOVE "T" TO TL-MODE
     MOVE "acceptance 19§22.4 35 ticks sent 35 Set Entity Data (the last one carries the 0)" TO TL-CASE
     MOVE "35" TO TL-EXPECTED
     PERFORM COUNT-DATA
     PERFORM CHECK
     MOVE 5 TO WS-TICK
     CALL "TEST-TICKS" USING WS-TICK
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance 19§22.4 a counter at 0 sends no more Set Entity Data" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM COUNT-DATA
     PERFORM CHECK
*>   The farmer has offers: the window opens, no head shake.
     MOVE "T" TO TL-MODE
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V2) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance 19§22.4 a villager with offers opens its window" TO TL-CASE
     MOVE "1" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     MOVE WS-N60 TO TL-OBSERVED
     PERFORM CHECK
     MOVE "N" TO TL-MODE
     MOVE WS-V2 TO WS-ROWKEY
     PERFORM FIND-DATA
     MOVE "acceptance 19§22.4 a villager with offers does not shake its head" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-F1 TO TL-OBSERVED-N
     PERFORM CHECK
     CALL "TEST-CLOSE-WIN" USING WS-CONN
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
*>   A baby villager is refused with the head shake too (no window).
     MOVE -24000 TO EN-MOBAGE(WS-V2)
     MOVE 1 TO EN-VARIANT(WS-V2)
     MOVE "T" TO TL-MODE
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V2) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "acceptance 19§22.4 a baby villager opens no window" TO TL-CASE
     MOVE "0" TO TL-EXPECTED
     PERFORM COUNT-OPEN
     MOVE WS-N60 TO TL-OBSERVED
     PERFORM CHECK
     MOVE "N" TO TL-MODE
     MOVE WS-V2 TO WS-ROWKEY
     PERFORM FIND-DATA
     MOVE "acceptance 19§22.4 a baby villager's refusal is the head shake (counter 40)" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     MOVE WS-F1 TO TL-OBSERVED-N
     PERFORM CHECK
*>   A sleeping villager ignores the click: no head shake.
     MOVE 0 TO EN-MOBAGE(WS-V1)
     MOVE 0 TO EN-VARIANT(WS-V1)
     MOVE 1 TO VL-SLEEP(WS-S1)
     MOVE "T" TO TL-MODE
     CALL "TEST-INTERACT" USING WS-CONN EN-ID(WS-V1) WS-HAND0 WS-SNEAK0
     CALL "TEST-DRAIN-IDS" USING WS-CONN WS-IDS
     MOVE "N" TO TL-MODE
     MOVE WS-V1 TO WS-ROWKEY
     PERFORM FIND-DATA
     MOVE "acceptance 19§22.4 a sleeping villager ignores the click: no head shake" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-F1 TO TL-OBSERVED-N
     PERFORM CHECK
     STOP RUN.

*> FIND-DATA: Set Entity Data as MOB-DATA-BUILD makes it for entity row WS-ROWKEY: entry 18 (the unhappy counter) into WS-F1, 0 when absent.
 FIND-DATA.
     MOVE 0 TO WS-F1
     CALL "PB-INIT" USING MQ-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROWKEY MQ-BUFFER
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         INITIALIZE MQ-METADATA-ENTRY-X
         CALL "PB-GET-METADATA-ENTRY-X" USING MQ-BUFFER MQ-METADATA-ENTRY-X
         IF MQ-MX-INDEX = MQ-MD-END OR MQ-ERROR = 1
             MOVE 1 TO WS-DONE
         ELSE
             IF MQ-MX-INDEX = 18
                 MOVE MQ-MX-INT TO WS-F1
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING MQ-BUFFER.

*> COUNT-OPEN: the Open Screen packets (60) of the drained ids into WS-N60 (0 or 1, as a digit).
 COUNT-OPEN.
     MOVE SPACES TO WS-SPACED
     STRING " " WS-IDS DELIMITED BY SIZE INTO WS-SPACED
     MOVE 0 TO WS-N60
     INSPECT WS-SPACED TALLYING WS-N60 FOR ALL " 60 " ALL " 60x"
     IF WS-N60 > 1
         MOVE 1 TO WS-N60
     END-IF.

*> COUNT-DATA: the number of Set Entity Data packets (101, written "101" or "101x<n>" in a run) of the drained ids into WS-N92 and TL-OBSERVED.
 COUNT-DATA.
     MOVE SPACES TO WS-SPACED
     STRING WS-IDS DELIMITED BY SIZE INTO WS-SPACED
     MOVE 0 TO WS-N92
     MOVE 1 TO WS-PTR
     PERFORM UNTIL WS-PTR > 1024
         MOVE SPACES TO WS-TOKEN
         UNSTRING WS-SPACED DELIMITED BY ALL SPACE INTO WS-TOKEN WITH POINTER WS-PTR
         IF WS-TOKEN = "101"
             ADD 1 TO WS-N92
         END-IF
         IF WS-TOKEN(1:4) = "101x"
             MOVE FUNCTION NUMVAL(WS-TOKEN(5:8)) TO WS-RUN
             ADD WS-RUN TO WS-N92
         END-IF
     END-PERFORM
     MOVE WS-N92 TO WS-E1
     MOVE FUNCTION TRIM(WS-E1) TO TL-OBSERVED.

 CHECK.
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM ACC-WRAPC-VILLAGER-UNHAPPY.
 COPY CORETEST.
 COPY BETEST.
