*> Merged-tree test (batch 7: 002-lane-villlook and 002-lane-villagers both send VILLAGER_DATA): the entity data of a villager, as MOB-DATA-BUILD writes it, holds
*> exactly one entry of index 19 (serializer 18) with the type, profession and level of the villager (profession id from VIL-PROF-ID). MOB-DATA-BUILD is the one
*> builder of both the spawn packet (entities.cob) and the changed-look packet (MOB-DATA-SEND), so one decode covers both. Checked for a default look, a farmer
*> (2 / 5 / 1 as acc_us15_villager_job_chain expects) and after a tick (STDMOB-STEP, VILLOOK-SYNC).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VILLAGER-DATA-ONCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY CONTENT.
 COPY BRWORLD.
 COPY STDMOBS.
 COPY VILSTATE.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-SLOT                BINARY-LONG.
 01 WS-NO                  BINARY-LONG VALUE 0.
 01 WS-BABY                BINARY-LONG.
 01 WS-WOOL                BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 256.
 01 WS-PK                  BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-CHANGED             BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
 01 WS-FLOOR               BINARY-LONG VALUE 40.
 01 WS-SIZE                BINARY-LONG VALUE 48.
 01 WS-STONE               BINARY-LONG VALUE 1.
 01 WS-X0                  BINARY-LONG.
 01 WS-Z0                  BINARY-LONG.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MQ-==.
 01 WS-COUNT              BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     COMPUTE WS-X0 = FUNCTION INTEGER(PL-X(WS-PLAYER)) - 24
     COMPUTE WS-Z0 = FUNCTION INTEGER(PL-Z(WS-PLAYER)) - 24
     CALL "MS-TEST-FLOOR" USING WS-DIM WS-X0 WS-Z0 WS-SIZE WS-FLOOR WS-STONE
     COMPUTE WS-X = WS-X0 + 24.5
     COMPUTE WS-Y = WS-FLOOR + 1
     COMPUTE WS-Z = WS-Z0 + 26.5
     MOVE "minecraft:villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ENTITY-ROW WS-STATUS
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE "N" TO TL-MODE
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT

*>   The default look (plains, none, level 1): one entry, as the client takes no entry as the same look.
     MOVE 2 TO VL-TYPE(WS-SLOT)
     MOVE "none" TO VL-PROF(WS-SLOT)
     MOVE 1 TO VL-LEVEL(WS-SLOT)
     PERFORM FIND-DATA
     MOVE "batch7 villager data: a default villager has one index-19 entry" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A plains farmer of level 1 (profession id 5).
     MOVE "farmer" TO VL-PROF(WS-SLOT)
     PERFORM FIND-DATA
     MOVE "batch7 villager data: a farmer has exactly one index-19 entry" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "batch7 villager data: the entry is serializer 18" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-SER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "batch7 villager data: type 2, profession 5, level 1 (as 2 5 1)" TO TL-CASE
     MOVE 251 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-T * 100 + WS-P * 10 + WS-L
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The changed look after a tick sent to the viewers: a level-2 librarian, still one entry.
     MOVE "librarian" TO VL-PROF(WS-SLOT)
     MOVE 2 TO VL-LEVEL(WS-SLOT)
     CALL "STDMOB-STEP" USING WS-ROW
     PERFORM FIND-DATA
     MOVE "batch7 villager data: after a tick the entry is still single" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "batch7 villager data: librarian is 9, level 2" TO TL-CASE
     MOVE 92 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-P * 10 + WS-L
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> FIND-DATA: decode MOB-DATA-BUILD for row WS-ROW: WS-COUNT entries of index 19, the last one's serializer WS-SER, type WS-T, profession WS-P, level WS-L
 FIND-DATA.
     CALL "PB-INIT" USING MQ-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW MQ-BUFFER
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     MOVE -1 TO WS-SER WS-T WS-P WS-L
     MOVE 0 TO WS-DONE WS-COUNT
     PERFORM UNTIL WS-DONE = 1
         INITIALIZE MQ-METADATA-ENTRY-X
         CALL "PB-GET-METADATA-ENTRY-X" USING MQ-BUFFER MQ-METADATA-ENTRY-X
         IF MQ-MX-INDEX = MQ-MD-END OR MQ-ERROR = 1
             MOVE 1 TO WS-DONE
         ELSE
             IF MQ-MX-INDEX = 19
                 ADD 1 TO WS-COUNT
                 MOVE MQ-MX-SERIALIZER TO WS-SER
                 MOVE MQ-MX-INT TO WS-T
                 MOVE MQ-MX-INT-2 TO WS-P
                 MOVE MQ-MX-INT-3 TO WS-L
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING MQ-BUFFER.
 END PROGRAM TEST-VILLAGER-DATA-ONCE.
 COPY CORETEST.
 COPY MOBSPTEST.
