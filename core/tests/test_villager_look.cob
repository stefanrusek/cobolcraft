*> Implementation test (002-lane-villlook; docs/protocol 34-entity-models-3 section 1.5 and 19 section 22, 46 section 6): the server sends the villager's look. A villager row sends
*> entity data 19, serializer 18 (VILLAGER_DATA: type id, profession id, level) when it differs from plains, none, level 1 (MOB-DATA-VALUES needed), VILLOOK-DATA writes it with the registry ids
*> of 46 section 6, and VILLOOK-CHANGED sees a profession or level change once (so a claimed workstation or a level up reaches the viewers).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-VILLAGER-LOOK.
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

*>   A plains villager without profession at level 1 is the default: nothing is sent.
     CALL "VL-FIND" USING EN-ID(WS-ROW) WS-NO WS-SLOT
     MOVE 2 TO VL-TYPE(WS-SLOT)
     MOVE "none" TO VL-PROF(WS-SLOT)
     MOVE 1 TO VL-LEVEL(WS-SLOT)
     CALL "MOB-DATA-VALUES" USING WS-ROW WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US16 34-3§1.5 Villager look: the default look sends no entity data" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VILLOOK-CHANGED" USING WS-ROW WS-CHANGED

*>   A swamp librarian at level 3.
     MOVE 5 TO VL-TYPE(WS-SLOT)
     MOVE "librarian" TO VL-PROF(WS-SLOT)
     MOVE 3 TO VL-LEVEL(WS-SLOT)
     CALL "MOB-DATA-VALUES" USING WS-ROW WS-BABY WS-WOOL WS-NEEDED
     MOVE "acceptance US16 34-3§1.5 Villager look: a villager with a profession sends entity data" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-NEEDED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     PERFORM FIND-DATA
     MOVE "acceptance US16 34-3§1.5 Villager look: entry 19 is VILLAGER_DATA (serializer 18)" TO TL-CASE
     MOVE 18 TO TL-EXPECTED-N
     MOVE WS-SER TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 34-3§1.5 Villager look: the type is swamp, id 5" TO TL-CASE
     MOVE 5 TO TL-EXPECTED-N
     MOVE WS-T TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 34-3§1.5 Villager look: the profession is librarian, id 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-P TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US16 34-3§1.5 Villager look: the level is 3" TO TL-CASE
     MOVE 3 TO TL-EXPECTED-N
     MOVE WS-L TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The change is seen once.
     CALL "VILLOOK-CHANGED" USING WS-ROW WS-CHANGED
     MOVE "acceptance US16 34-3§1.5 Villager look: a new profession is a change" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "VILLOOK-CHANGED" USING WS-ROW WS-CHANGED
     MOVE "acceptance US16 34-3§1.5 Villager look: the same look is no change" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 4 TO VL-LEVEL(WS-SLOT)
     CALL "VILLOOK-SYNC" USING WS-ROW
     CALL "VILLOOK-CHANGED" USING WS-ROW WS-CHANGED
     MOVE "acceptance US16 34-3§1.5 Villager look: VILLOOK-SYNC takes the level up as sent" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   A nitwit (id 11) and a weaponsmith (id 14).
     MOVE "nitwit" TO VL-PROF(WS-SLOT)
     PERFORM FIND-DATA
     MOVE "acceptance US16 46§6.2 Villager look: nitwit is profession id 11" TO TL-CASE
     MOVE 11 TO TL-EXPECTED-N
     MOVE WS-P TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "weaponsmith" TO VL-PROF(WS-SLOT)
     PERFORM FIND-DATA
     MOVE "acceptance US16 46§6.2 Villager look: weaponsmith is profession id 14" TO TL-CASE
     MOVE 14 TO TL-EXPECTED-N
     MOVE WS-P TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A tick of the villager (STDMOB-STEP) sends a look that changed: a nitwit (it keeps the profession without a workstation) of level 2.
     MOVE "nitwit" TO VL-PROF(WS-SLOT)
     MOVE 2 TO VL-LEVEL(WS-SLOT)
     CALL "STDMOB-STEP" USING WS-ROW
     CALL "VILLOOK-CHANGED" USING WS-ROW WS-CHANGED
     MOVE "acceptance US16 34-3§1.5 Villager look: a tick sends the changed look to the viewers" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CHANGED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

*> FIND-DATA: the entry 19 of MOB-DATA-BUILD for row WS-ROW: serializer WS-SER (-1 when absent), type WS-T, profession WS-P, level WS-L
 FIND-DATA.
     CALL "PB-INIT" USING MQ-BUFFER WS-CAPACITY
     CALL "MOB-DATA-BUILD" USING WS-ROW MQ-BUFFER
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     CALL "PB-GET-VARINT" USING MQ-BUFFER WS-PK
     MOVE -1 TO WS-SER WS-T WS-P WS-L
     MOVE 0 TO WS-DONE
     PERFORM UNTIL WS-DONE = 1
         INITIALIZE MQ-METADATA-ENTRY-X
         CALL "PB-GET-METADATA-ENTRY-X" USING MQ-BUFFER MQ-METADATA-ENTRY-X
         IF MQ-MX-INDEX = MQ-MD-END OR MQ-ERROR = 1
             MOVE 1 TO WS-DONE
         ELSE
             IF MQ-MX-INDEX = 19
                 MOVE MQ-MX-SERIALIZER TO WS-SER
                 MOVE MQ-MX-INT TO WS-T
                 MOVE MQ-MX-INT-2 TO WS-P
                 MOVE MQ-MX-INT-3 TO WS-L
             END-IF
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING MQ-BUFFER.
 END PROGRAM TEST-VILLAGER-LOOK.
 COPY CORETEST.
 COPY MOBSPTEST.
