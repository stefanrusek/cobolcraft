 *> Villager hat metadata (34-3 1.5): the `villager` section of the .mcmeta of the type texture (folder type, also for a baby) and of the profession texture gives `hat` none (default),
*> partial or full. The type layer draws the whole model when the profession's hat is none, or partial with a type that is not full; else the no-hat model (rows villager_nohat,
*> villager_nohat~b, zvillager_nohat, zvillager_nohat~b: no head cuboids). A missing file, a missing section, an unknown value or a file that is not JSON is none.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-VILLAGER-HAT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-DIR                 PIC X(64) VALUE "build/client-test-villager-hat".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 30.
 01 WS-NAMES               PIC X(256) VALUE "villagerhat".
 01 WS-IDS                 PIC X(256) VALUE "file/villagerhat".
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-I-D                 PIC 99.
 01 WS-CODE                BINARY-LONG.
 01 WS-RED                 FLOAT-LONG.
 01 WS-GREEN               FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-K20                 PIC X(20).
 01 WS-PATH                PIC X(64).
 01 WS-TCODE               BINARY-LONG.
 01 WS-HAT                 BINARY-LONG.
 01 WS-CASES-DATA.
*>   kind (1 villager, 2 zombie villager), baby, type, profession, expected model row key
    05 FILLER PIC X(40) VALUE "1 0 2 1 villager_nohat".
    05 FILLER PIC X(40) VALUE "1 0 0 1 -".
    05 FILLER PIC X(40) VALUE "1 0 0 2 villager_nohat".
    05 FILLER PIC X(40) VALUE "1 0 2 4 -".
    05 FILLER PIC X(40) VALUE "1 0 2 5 -".
    05 FILLER PIC X(40) VALUE "1 0 2 6 -".
    05 FILLER PIC X(40) VALUE "1 0 5 2 villager_nohat".
    05 FILLER PIC X(40) VALUE "1 0 2 0 -".
    05 FILLER PIC X(40) VALUE "1 1 2 1 villager_nohat~b".
    05 FILLER PIC X(40) VALUE "2 0 2 2 zvillager_nohat".
    05 FILLER PIC X(40) VALUE "2 1 2 2 zvillager_nohat~b".
    05 FILLER PIC X(40) VALUE "2 0 0 2 zvillager_nohat".
    05 FILLER PIC X(40) VALUE "1 0 1 1 -".
 01 WS-CASES REDEFINES WS-CASES-DATA.
    05 WS-CASE OCCURS 13 TIMES.
       10 WS-C-KIND        PIC 9.
       10 FILLER           PIC X.
       10 WS-C-BABY        PIC 9.
       10 FILLER           PIC X.
       10 WS-C-TYPE        PIC 9.
       10 FILLER           PIC X.
       10 WS-C-PROF        PIC 9.
       10 FILLER           PIC X.
       10 WS-C-EXPECT      PIC X(32).
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-PACK-START" USING CLIENT-STATE WS-DIR WS-DIR-LENGTH WS-NAMES
     CALL "TEST-PACK-ENABLE" USING CLIENT-STATE WS-IDS
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 13
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         IF WS-C-KIND(WS-I) = 1
             MOVE "villager" TO WS-KEY
         ELSE
             MOVE "zombie_villager" TO WS-KEY
         END-IF
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 1 TO WS-ID
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         MOVE WS-C-TYPE(WS-I) TO EN-VAR(1)
         MOVE WS-C-PROF(WS-I) TO EN-VAR2(1)
         MOVE 1 TO EN-VAR3(1)
         MOVE WS-C-BABY(WS-I) TO EN-BABY(1)
         CALL "ENTITY-OVERLAY" USING CLIENT-STATE 1 1 WS-CODE WS-RED WS-GREEN WS-BLUE WS-MODEL
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         MOVE WS-I TO WS-I-D
         STRING "acceptance villager hat case " WS-I-D " model of the type layer" DELIMITED BY SIZE INTO TL-CASE
         MOVE SPACES TO TL-EXPECTED TL-OBSERVED
         MOVE WS-C-EXPECT(WS-I) TO TL-EXPECTED
         MOVE "-" TO TL-OBSERVED
         IF WS-MODEL > 0
             MOVE CL-MD-KEY(WS-MODEL) TO TL-OBSERVED
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The textures of the no-hat rows are those of the layer they stand in for: the same type, profession and level folders (a baby type in the baby folder).
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 5
         EVALUATE WS-I
             WHEN 1
                 MOVE "villager_nohat" TO WS-K20
                 MOVE 1003 TO WS-TCODE
                 MOVE "textures/entity/villager/type/plains.png" TO TL-EXPECTED
             WHEN 2
                 MOVE "villager_nohat~b" TO WS-K20
                 MOVE 1003 TO WS-TCODE
                 MOVE "textures/entity/villager/baby/plains.png" TO TL-EXPECTED
             WHEN 3
                 MOVE "zvillager_nohat" TO WS-K20
                 MOVE 1003 TO WS-TCODE
                 MOVE "textures/entity/zombie_villager/type/plains.png" TO TL-EXPECTED
             WHEN 4
                 MOVE "zvillager_nohat~b" TO WS-K20
                 MOVE 1003 TO WS-TCODE
                 MOVE "textures/entity/zombie_villager/baby/plains.png" TO TL-EXPECTED
             WHEN OTHER
                 MOVE "villager" TO WS-K20
                 MOVE 1003 TO WS-TCODE
                 MOVE "textures/entity/villager/type/plains.png" TO TL-EXPECTED
         END-EVALUATE
         CALL "ENTITY-TEX-PATH" USING WS-K20 WS-TCODE WS-PATH
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "acceptance villager hat texture of " FUNCTION TRIM(WS-K20) DELIMITED BY SIZE INTO TL-CASE
         MOVE WS-PATH TO TL-OBSERVED
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
*>   The no-hat layer draws no head: the villager's 11 cuboids without head, hat, hat_rim and nose (4 of them) are 7; the same through ENTITIES-MESH with the layers.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 2 TO EN-VAR(1)
     MOVE 2 TO EN-VAR2(1)
     MOVE 3 TO EN-VAR3(1)
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 256 TO PL-HEIGHT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "N" TO TL-MODE
     MOVE "acceptance villager hat plains butcher: villager 11 + no-hat type layer 7 + profession 11 + level 11 cuboids" TO TL-CASE
     MOVE 1440 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The metadata cache holds 64 paths and then replaces the oldest: 70 paths without a file wrap it, and the plains (full) and desert (partial) types are still read right.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 70
         MOVE WS-I TO WS-I-D
         MOVE SPACES TO WS-PATH
         STRING "textures/entity/villager/type/none" WS-I-D ".png" DELIMITED BY SIZE INTO WS-PATH
         CALL "VILLAGER-HAT" USING CLIENT-STATE WS-PATH WS-HAT
     END-PERFORM
     MOVE "textures/entity/villager/type/plains.png" TO WS-PATH
     CALL "VILLAGER-HAT" USING CLIENT-STATE WS-PATH WS-HAT
     MOVE "acceptance villager hat plains is full after the cache wrapped" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-HAT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "textures/entity/villager/type/desert.png" TO WS-PATH
     CALL "VILLAGER-HAT" USING CLIENT-STATE WS-PATH WS-HAT
     MOVE "acceptance villager hat desert is partial after the cache wrapped" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-HAT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-VILLAGER-HAT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MM-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM MM-SPAWN.


 COPY CLTEST.
 COPY PACKTEST.
