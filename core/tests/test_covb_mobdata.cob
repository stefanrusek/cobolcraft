*> Implementation test (lane covB; docs/protocol/20 section 4.2, 44 part 4 section 15): entity data of a baby zombie villager that is being cured (two entries: the baby flag and the converting
*> flag) against one that is not, and a bee whose pollination ends with nectar (the nectar flag changes, so its data is sent).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-COVB-MOBDATA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-ZV                  BINARY-LONG.
 01 WS-BEE                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-LENGTH1             BINARY-LONG.
 01 WS-HX                 FLOAT-LONG.
 01 WS-HZ                 FLOAT-LONG.
 01 WS-WALK               BINARY-LONG.
 01 WS-CREATE              BINARY-LONG VALUE 1.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE "N" TO TL-MODE
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X = PL-X(WS-PLAYER) + 5
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE "minecraft:zombie_villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-ZV
     MOVE 1 TO EN-VARIANT(WS-ZV)
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ZV PB-BUFFER
     MOVE PB-LENGTH TO WS-LENGTH1
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ZC-FIND" USING EN-ID(WS-ZV) WS-CREATE WS-SLOT
     CALL "STDMOB-VARIANT-BUILD" USING WS-ZV PB-BUFFER
     MOVE "covB 20 4.2 a baby zombie villager being cured sends a second entry (the converting flag)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PB-LENGTH > WS-LENGTH1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-FREE" USING PB-BUFFER
*>   A bee that pollinated long enough carries nectar at the end of the pollination.
     MOVE "minecraft:bee" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-T WS-ENTITY-ROW WS-STATUS
     ADD 3 TO WS-X
     CALL "MOB-SPAWN" USING WS-DIM WS-T WS-X WS-Y WS-Z WS-YAW WS-BEE
     MOVE 5 TO EN-BEE-POLL(WS-BEE)
     MOVE 401 TO EN-BEE-SUCC(WS-BEE)
     MOVE 0 TO EN-BEE-NECTAR(WS-BEE) EN-BEE-FL-ON(WS-BEE) EN-BEE-HV-ON(WS-BEE) EN-TARGET(WS-BEE) EN-BEE-STUNG(WS-BEE)
     MOVE 50 TO EN-BEE-VAL(WS-BEE)
     CALL "BEE-TICK" USING WS-BEE WS-HX WS-HZ WS-WALK
     MOVE "covB 19 16 a bee whose pollination ended after more than 400 good ticks carries nectar" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-BEE-NECTAR(WS-BEE) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-COVB-MOBDATA.
 COPY CORETEST.
 COPY MOBSPTEST.
