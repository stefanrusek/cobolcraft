 *> Baked meshes of the entity models (ENTITY-MODEL-EMIT): every layer of a mob (the model, the extra layer, each overlay layer) keeps its own baked mesh, so a frame
*> that changes nothing bakes nothing; the eye-relative corners are shifted only when the offset to the eye changed (RL-EN-BAKES, RL-EN-SHIFTS count them).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-BAKE-CACHE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-B0                  BINARY-LONG.
 01 WS-S0                  BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-X1                  FLOAT-SHORT.
 01 WS-X2                  FLOAT-SHORT.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-CUBOIDS             BINARY-LONG.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.

 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE 1 TO CT-OPEN
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
*>   A villager (type plains, profession armorer, level 3: the model and three overlay layers), a sheep (wool, the extra layer) and a horse with markings.
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 10.5 TO WS-X
     MOVE 10.5 TO WS-Z
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 2 TO EN-VAR(1)
     MOVE 1 TO EN-VAR2(1)
     MOVE 3 TO EN-VAR3(1)
     MOVE "sheep" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 14.5 TO WS-X
     MOVE 2 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE "horse" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 18.5 TO WS-X
     MOVE 3 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 513 TO EN-VAR(3)
     MOVE RL-EN-BAKES TO WS-B0
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "N" TO TL-MODE
     MOVE "acceptance bake cache the first frame bakes the layers" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-BAKES - WS-B0 >= 6
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE RL-EN-COUNT TO WS-V1
     MOVE RL-EN-X(1) TO WS-X1
     COMPUTE WS-CUBOIDS = RL-EN-COUNT / 36
     MOVE RL-EN-BAKES TO WS-B0
     MOVE RL-EN-SHIFTS TO WS-S0
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance bake cache a second frame bakes nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-EN-BAKES - WS-B0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bake cache a second frame shifts nothing (the eye did not move)" TO TL-CASE
     COMPUTE TL-OBSERVED-N = RL-EN-SHIFTS - WS-S0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bake cache the second frame has the same vertices" TO TL-CASE
     MOVE WS-V1 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bake cache the second frame has the same first vertex" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-X(1) = WS-X1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The eye moves one block east: every cuboid is shifted again and every x is one block less; the eye back again gives the first vertex.
     MOVE 11 TO WS-EYE(1)
     MOVE RL-EN-SHIFTS TO WS-S0
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance bake cache a moved eye shifts every cuboid" TO TL-CASE
     MOVE WS-CUBOIDS TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = RL-EN-SHIFTS - WS-S0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-DIFF = WS-X1 - RL-EN-X(1)
     MOVE "acceptance bake cache a moved eye moves the vertices by one block" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF > 0.999 AND WS-DIFF < 1.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 10 TO WS-EYE(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance bake cache the eye back gives the first vertex" TO TL-CASE
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-X(1) = WS-X1
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bake cache the eye back bakes nothing" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE RL-EN-BAKES TO WS-B0
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     COMPUTE TL-OBSERVED-N = RL-EN-BAKES - WS-B0
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   More layers than the cache holds (256 villagers of four layers): a frame is still drawn whole, the next one re-bakes what was recycled.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 256
         COMPUTE WS-X = 2 + FUNCTION MOD(WS-I, 16) * 2
         COMPUTE WS-Z = 2 + FUNCTION INTEGER(WS-I / 16) * 2
         MOVE WS-I TO WS-ID
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         MOVE 2 TO EN-VAR(WS-I)
         MOVE 1 TO EN-VAR2(WS-I)
         MOVE 3 TO EN-VAR3(WS-I)
     END-PERFORM
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE RL-EN-COUNT TO WS-V1
     MOVE RL-EN-BAKES TO WS-B0
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance bake cache 1024 layers: the second frame has the same vertices" TO TL-CASE
     MOVE WS-V1 TO TL-EXPECTED-N
     MOVE RL-EN-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance bake cache 1024 layers: some are baked again" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-BAKES > WS-B0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-BAKE-CACHE.

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
