*> Acceptance test (lane p49a; docs/protocol/45-entity-nbt-2 section 4, 18 sections 2.10 and 7.1): the mob flags are saved and loaded: NoAI (written only when true) and
*> LeftHanded (bit 2 of the mob flags byte); a mob that is loaded with the flags has them again, a mob without them has none; the Set Entity Data of index 15 carries the
*> byte (1 no AI, 2 left-handed, 3 both) to the viewers; finalizeSpawn rolls left-handedness on 5 percent of mobs and gives every mob a follow_range spread modifier.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-18-2-10-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY CONTENT.
 COPY PROTO.
 COPY BRWORLD.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-CONN                BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG VALUE 1.
 01 WS-CZ                  BINARY-LONG VALUE 2.
 01 WS-KEY                 PIC X(112).
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-COW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 90.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROW2                BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-LEFTIES             BINARY-LONG.
 01 WS-BONUSES             BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-SEED                BINARY-DOUBLE UNSIGNED.
 COPY XORO.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 2 TO CS-VIEW-DISTANCE
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "TEST-STANDARD-TABLES"
     CALL "BR-WORLD-READY"
     MOVE 2 TO BW-DIFFICULTY
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-CONN
     MOVE CN-PLAYER(WS-CONN) TO WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE 6000 TO CW-TIME
     MOVE "minecraft:cow" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-COW WS-ENTITY-ROW WS-STATUS
     MOVE 20.5 TO WS-X
     MOVE 55 TO WS-Y
     MOVE 37.25 TO WS-Z
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
     MOVE 1 TO EN-NO-AI(WS-ROW) EN-LEFTY(WS-ROW)
     MOVE 25.5 TO WS-X
     CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW2
     MOVE 0 TO EN-NO-AI(WS-ROW2) EN-LEFTY(WS-ROW2)

     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT
     MOVE "Entities" TO WS-PATH
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     MOVE "N" TO TL-MODE
     MOVE "mob flags: the payload of the flagged cow holds LeftHanded:1 and NoAI:1" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO WS-A WS-B
     INSPECT WS-TEXT TALLYING WS-A FOR ALL "LeftHanded:1"
     INSPECT WS-TEXT TALLYING WS-B FOR ALL "NoAI:1"
     MOVE 0 TO TL-OBSERVED-N
     IF WS-A = 1 AND WS-B = 1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mob flags: the other cow writes neither (one of each in two mobs)" TO TL-CASE
     MOVE 0 TO WS-A WS-B
     INSPECT WS-TEXT TALLYING WS-A FOR ALL "{id:minecraft:cow"
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-A TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     CALL "ENTITY-REMOVE" USING WS-ROW
     CALL "ENTITY-REMOVE" USING WS-ROW2
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-A WS-B WS-SEEN
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0
             ADD 1 TO WS-SEEN
             IF EN-NO-AI(WS-I) = 1 AND EN-LEFTY(WS-I) = 1
                 ADD 1 TO WS-A
             END-IF
             IF EN-NO-AI(WS-I) = 0 AND EN-LEFTY(WS-I) = 0
                 ADD 1 TO WS-B
             END-IF
         END-IF
     END-PERFORM
     MOVE "mob flags: both cows come back, one with both flags and one with none" TO TL-CASE
     MOVE 211 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = WS-SEEN * 100 + WS-A * 10 + WS-B
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   Set Entity Data of index 15 is built for a flagged mob and for none else.
     MOVE 0 TO WS-A
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         IF EN-USED(WS-I) = 1 AND EN-PLAYER(WS-I) = 0 AND EN-NO-AI(WS-I) = 1
             MOVE WS-I TO WS-ROW
         END-IF
     END-PERFORM
     CALL "PB-RESET" USING PB-BUFFER
     CALL "STDMOB-FLAGS-BUILD" USING WS-ROW PB-BUFFER
     MOVE "mob flags: a flagged mob builds a Set Entity Data packet" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF PB-LENGTH > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "PB-RESET" USING PB-BUFFER
     MOVE 0 TO EN-NO-AI(WS-ROW) EN-LEFTY(WS-ROW)
     CALL "STDMOB-FLAGS-BUILD" USING WS-ROW PB-BUFFER
     MOVE "mob flags: no flag set builds nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PB-LENGTH TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   finalizeSpawn steps 1 and 2: 400 mobs, about 5 percent left-handed, every one with a follow_range spread within +-0.11485.
     MOVE 0 TO WS-LEFTIES WS-BONUSES
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 400
         MOVE 20.5 TO WS-X
         CALL "MOB-SPAWN" USING WS-DIM WS-COW WS-X WS-Y WS-Z WS-YAW WS-ROW
         COMPUTE CW-TIME = 6000 + WS-I
         CALL "STDMOB-FINALIZE-BASE" USING WS-ROW
         ADD EN-LEFTY(WS-ROW) TO WS-LEFTIES
         IF EN-FOLLOW-BONUS(WS-ROW) NOT = 0 AND EN-FOLLOW-BONUS(WS-ROW) > -114851 AND EN-FOLLOW-BONUS(WS-ROW) < 114851
             ADD 1 TO WS-BONUSES
         END-IF
         CALL "ENTITY-REMOVE" USING WS-ROW
     END-PERFORM
     MOVE "mob flags: about 5 percent of 400 finalized mobs are left-handed (between 8 and 40)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LEFTIES >= 8 AND WS-LEFTIES <= 40
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "mob flags: nearly every mob gets a non-zero follow_range spread inside the triangle's bounds (at least 395)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BONUSES >= 395
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-MOB-18-2-10-NBT.

 COPY CORETEST.
