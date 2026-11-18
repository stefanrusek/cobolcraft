*> Loot, spawn weights in structures (docs/protocol/44-residual-mob-questions-6-nether.md section 10; lane 002-lane-p49c, T15550): hoglin porkchop 2 to 4 and leather 0 to 1,
*> zoglin rotten flesh 1 to 3, strider string 2 to 5 (killed by a player, 60 kills each), and the fortress spawn overrides (blaze 10 x 2-3, zombified piglin 5 x 4, wither
*> skeleton 8 x 5, skeleton 2 x 5, magma cube 3 x 4).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-Q44-44-6-10.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY PROTO.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ITEM-TYPE           BINARY-LONG.
 01 WS-HTYPE               BINARY-LONG.
 01 WS-ZTYPE               BINARY-LONG.
 01 WS-STYPE               BINARY-LONG.
 01 WS-PORK                BINARY-LONG.
 01 WS-LEATHER             BINARY-LONG.
 01 WS-FLESH               BINARY-LONG.
 01 WS-STRING              BINARY-LONG.
 01 WS-WHICH               BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-PMIN                BINARY-LONG.
 01 WS-PMAX                BINARY-LONG.
 01 WS-PN                  BINARY-LONG.
 01 WS-LMIN                BINARY-LONG.
 01 WS-LMAX                BINARY-LONG.
 01 WS-LN                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-NO-SHEEP            BINARY-LONG VALUE -1.
 01 WS-LEN                 BINARY-LONG.
 01 WS-ENT                 PIC X(24).
 01 WS-WEIGHT              BINARY-LONG.
 01 WS-MIN                 BINARY-LONG.
 01 WS-MAX                 BINARY-LONG.
 01 WS-E1                  PIC 9.
 01 WS-E2                  PIC Z9.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-ENV                 PIC X(1024).
 01 WS-DIR                 PIC X(1024).
 01 WS-FILE                PIC X(1100).
 01 WS-FILE-INFO           PIC X(16).
 01 WS-E3                  PIC 9.
 01 WS-E4                  PIC 9.
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
         MOVE "acceptance US15 44-6§10 no generated packs here, skipped" TO TL-CASE
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
     MOVE "Loot" TO CS-NEW-WORLD-NAME
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE 0 TO PL-MODE(WS-PLAYER)
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE "item" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ITEM-TYPE WS-ENTITY-ROW WS-STATUS
     MOVE "hoglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-HTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "zoglin" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-ZTYPE WS-ENTITY-ROW WS-STATUS
     MOVE "strider" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-STYPE WS-ENTITY-ROW WS-STATUS
     MOVE "porkchop" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-PORK
     MOVE "leather" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-LEATHER
     MOVE "rotten_flesh" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-FLESH
     MOVE "string" TO WS-KEY
     CALL "TEST-ITEM-ID" USING WS-KEY WS-STRING
     MOVE PL-Y(WS-PLAYER) TO WS-Y
     MOVE 99 TO WS-PMIN WS-LMIN
     MOVE 0 TO WS-PMAX WS-LMAX
*>   Hoglin: 60 kills; porkchop count per kill, leather count per kill.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         COMPUTE WS-X = PL-X(WS-PLAYER) + WS-I * 0.37
         MOVE PL-Z(WS-PLAYER) TO WS-Z
         CALL "STDMOB-DROPS" USING WS-DIM WS-X WS-Y WS-Z WS-HTYPE WS-PLAYER WS-NO-SHEEP
         MOVE WS-PORK TO WS-WHICH
         PERFORM SUM-AND-CLEAR
         MOVE WS-PN TO WS-K
         IF WS-K < WS-PMIN
             MOVE WS-K TO WS-PMIN
         END-IF
         IF WS-K > WS-PMAX
             MOVE WS-K TO WS-PMAX
         END-IF
         MOVE WS-LN TO WS-K
         IF WS-K < WS-LMIN
             MOVE WS-K TO WS-LMIN
         END-IF
         IF WS-K > WS-LMAX
             MOVE WS-K TO WS-LMAX
         END-IF
     END-PERFORM
     MOVE "acceptance US15 44-6§10 hoglin porkchop count 2 to 4 (min, max over 60 kills)" TO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE "2 4" TO TL-EXPECTED
     MOVE WS-PMIN TO WS-E1
     MOVE WS-PMAX TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance US15 44-6§10 hoglin leather count 0 to 1" TO TL-CASE
     MOVE "0 1" TO TL-EXPECTED
     MOVE WS-LMIN TO WS-E1
     MOVE WS-LMAX TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Zoglin rotten flesh 1 to 3.
     MOVE 99 TO WS-PMIN
     MOVE 0 TO WS-PMAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         COMPUTE WS-X = PL-X(WS-PLAYER) + WS-I * 0.37
         MOVE PL-Z(WS-PLAYER) TO WS-Z
         CALL "STDMOB-DROPS" USING WS-DIM WS-X WS-Y WS-Z WS-ZTYPE WS-PLAYER WS-NO-SHEEP
         MOVE WS-FLESH TO WS-WHICH
         PERFORM SUM-AND-CLEAR
         MOVE WS-PN TO WS-K
         IF WS-K < WS-PMIN
             MOVE WS-K TO WS-PMIN
         END-IF
         IF WS-K > WS-PMAX
             MOVE WS-K TO WS-PMAX
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 44-6§10 zoglin rotten flesh 1 to 3" TO TL-CASE
     MOVE "1 3" TO TL-EXPECTED
     MOVE WS-PMIN TO WS-E1
     MOVE WS-PMAX TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
*>   Strider string 2 to 5.
     MOVE 99 TO WS-PMIN
     MOVE 0 TO WS-PMAX
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 60
         COMPUTE WS-X = PL-X(WS-PLAYER) + WS-I * 0.37
         MOVE PL-Z(WS-PLAYER) TO WS-Z
         CALL "STDMOB-DROPS" USING WS-DIM WS-X WS-Y WS-Z WS-STYPE WS-PLAYER WS-NO-SHEEP
         MOVE WS-STRING TO WS-WHICH
         PERFORM SUM-AND-CLEAR
         MOVE WS-PN TO WS-K
         IF WS-K < WS-PMIN
             MOVE WS-K TO WS-PMIN
         END-IF
         IF WS-K > WS-PMAX
             MOVE WS-K TO WS-PMAX
         END-IF
     END-PERFORM
     MOVE "T" TO TL-MODE
     MOVE "acceptance US15 44-6§10 strider string 2 to 5" TO TL-CASE
     MOVE "2 5" TO TL-EXPECTED
     MOVE WS-PMIN TO WS-E1
     MOVE WS-PMAX TO WS-E3
     MOVE SPACES TO TL-OBSERVED
     STRING WS-E1 " " WS-E3 DELIMITED BY SIZE INTO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Fortress overrides: blaze 10 x 2-3, zombified piglin 5 x 4, wither skeleton 8 x 5, skeleton 2 x 5, magma cube 3 x 4.
     MOVE "blaze 10 2 3|zombified_piglin 5 4 4|wither_skeleton 8 5 5|skeleton 2 5 5|magma_cube 3 4 4|" TO TL-EXPECTED
     MOVE SPACES TO TL-OBSERVED
     MOVE 1 TO WS-K
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         CALL "NETHER-FORTRESS-SPAWN" USING WS-I WS-ENT WS-LEN WS-WEIGHT WS-MIN WS-MAX
         MOVE WS-WEIGHT TO WS-E2
         MOVE WS-MIN TO WS-E3
         MOVE WS-MAX TO WS-E4
         STRING FUNCTION TRIM(WS-ENT) " " FUNCTION TRIM(WS-E2) " " WS-E3 " " WS-E4 "|" DELIMITED BY SIZE INTO TL-OBSERVED WITH POINTER WS-K
     END-PERFORM
     MOVE "acceptance US15 44-6§10 the fortress spawn overrides" TO TL-CASE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "N" TO TL-MODE
     STOP RUN.

 SUM-AND-CLEAR.
     MOVE 0 TO WS-PN WS-LN
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > EN-COUNT
         IF EN-USED(WS-K) = 1 AND EN-TYPE(WS-K) = WS-ITEM-TYPE
             IF EN-ITEM(WS-K) = WS-WHICH
                 ADD EN-ITEM-COUNT(WS-K) TO WS-PN
             END-IF
             IF EN-ITEM(WS-K) = WS-LEATHER
                 ADD EN-ITEM-COUNT(WS-K) TO WS-LN
             END-IF
             CALL "ENTITY-REMOVE" USING WS-K
         END-IF
     END-PERFORM.
 END PROGRAM TEST-Q44-44-6-10.
 COPY CORETEST.
 COPY BETEST.
