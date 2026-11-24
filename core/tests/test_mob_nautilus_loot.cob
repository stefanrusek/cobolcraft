*> Implementation test (wrap C round 7, T24090; 21 section 4.10 and 20 section 18): the loot tables of the nautilus family through the rows of the mob table. Killed by a player the zombie nautilus drops
*> rotten flesh U(0..3), the nautilus a nautilus shell with chance 0.05 (a world of the generated vanilla data, as test_q44_44_6_10 opens it: the loaded tables are the real ones).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-NAUTILUS-LOOT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-NO-SHEEP            BINARY-LONG VALUE -1.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM-TYPE           BINARY-LONG.
 01 WS-NAUTILUS            BINARY-LONG.
 01 WS-ZOMBIE              BINARY-LONG.
 01 WS-FLESH               BINARY-LONG.
 01 WS-SHELL               BINARY-LONG.
 01 WS-WHICH               BINARY-LONG.
 01 WS-PN                  BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-T                   BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-LARGEST             BINARY-LONG.
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
         MOVE "implementation 21 4.10 no generated packs here, skipped" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 1 TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         STOP RUN
     END-IF
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE "standard" TO CS-WORLD-TYPE
     MOVE WS-DIR TO CS-GENERATED-DIR
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     MOVE "12345" TO CS-SEED-TEXT
     MOVE "NautilusLoot" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-NAUTILUS WS-ENTITY-ROW WS-STATUS
     MOVE "zombie_nautilus" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZOMBIE WS-ENTITY-ROW WS-STATUS
     MOVE "rotten_flesh" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-FLESH
     MOVE "nautilus_shell" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-SHELL
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE PL-Z(WS-PLAYER) TO WS-Z
     MOVE 0 TO WS-TOTAL WS-LARGEST
     MOVE WS-FLESH TO WS-WHICH
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 60
         COMPUTE WS-X = PL-X(WS-PLAYER) + WS-T * 0.37
         CALL "STDMOB-DROPS" USING WS-DIM WS-X WS-Y WS-Z WS-ZOMBIE WS-PLAYER WS-NO-SHEEP
         PERFORM SUM-AND-CLEAR
         ADD WS-PN TO WS-TOTAL
         IF WS-PN > WS-LARGEST
             MOVE WS-PN TO WS-LARGEST
         END-IF
     END-PERFORM
     MOVE "implementation 20 18 a zombie nautilus killed by a player drops rotten flesh, most kills give some and at most 3 (60 kills)" TO TL-CASE
     MOVE 13 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TOTAL > 20
         ADD 10 TO TL-OBSERVED-N
     END-IF
     IF WS-LARGEST <= 3
         ADD 3 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-TOTAL
     MOVE WS-SHELL TO WS-WHICH
     PERFORM VARYING WS-T FROM 1 BY 1 UNTIL WS-T > 300
         COMPUTE WS-X = PL-X(WS-PLAYER) + WS-T * 0.37
         CALL "STDMOB-DROPS" USING WS-DIM WS-X WS-Y WS-Z WS-NAUTILUS WS-PLAYER WS-NO-SHEEP
         PERFORM SUM-AND-CLEAR
         ADD WS-PN TO WS-TOTAL
     END-PERFORM
     MOVE "implementation 21 4.10 a nautilus killed by a player drops a nautilus shell now and then (300 kills: some, far fewer than all)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-TOTAL > 0 AND WS-TOTAL < 100
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 SUM-AND-CLEAR.
     MOVE 0 TO WS-PN
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-TYPE(WS-K) = WS-ITEM-TYPE
             IF EN-ITEM(WS-K) = WS-WHICH
                 ADD EN-ITEM-COUNT(WS-K) TO WS-PN
             END-IF
             CALL "ENTITY-REMOVE" USING WS-K
         END-IF
     END-PERFORM.
 END PROGRAM TEST-MOB-NAUTILUS-LOOT.
 COPY CORETEST.
 COPY BETEST.
