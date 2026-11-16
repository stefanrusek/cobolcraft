*> Guardian client state (34-6 11.3 and 11.4): Set Entity Data entry 16 (moving, BOOLEAN) and 17 (active attack target id, VarInt) are kept in EN-X1 and EN-TGT; ENTITIES-ANIM-TICK runs
*> EF6-GUARDIAN-TICK (tail speed EN-TS, tail animation EN-TM, spikes animation EN-TA, in water from EN-DRY) and EF6-GUARDIAN-ATTACK-TICK (attack time EN-RS, duration 80, elder 60);
*> the model is posed with the spikes and tail values (ENTITY-POSE-MORE: L-I(16) spikes, L-I(14) tail).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-GUARDIAN.
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
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ID                  BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-BX                  BINARY-LONG VALUE 10.
 01 WS-BY                  BINARY-LONG VALUE 64.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SER                 BINARY-LONG.
 01 WS-V1                  BINARY-LONG.
 01 WS-V2                  BINARY-LONG.
 01 WS-V3                  BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE VALUE 0.
 01 WS-DIFF                FLOAT-LONG.
 01 WS-SUM1                FLOAT-LONG.
 01 WS-SUM2                FLOAT-LONG.
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
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 1 TO ST-FLUID(5)
     MOVE 0 TO ST-LEVEL(5) ST-OPAQUE(5)
     MOVE 4 TO WS-V1
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-BX WS-BY WS-BX WS-V1
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "guardian" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 1 TO WS-ROW
*>   Metadata: moving (16, BOOLEAN) and the target (17, VarInt); the target change restarts the attack time.
     MOVE 16 TO WS-INDEX
     MOVE 8 TO WS-SER
     MOVE 1 TO WS-V1
     MOVE 0 TO WS-V2 WS-V3
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE WS-ROW WS-INDEX WS-SER WS-V1 WS-V2 WS-V3 WS-LONG
     MOVE "acceptance guardian moving flag" TO TL-CASE
     MOVE EN-X1(1) TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE 5 TO EN-RS(1)
     MOVE 17 TO WS-INDEX
     MOVE 1 TO WS-SER
     MOVE 7 TO WS-V1
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE WS-ROW WS-INDEX WS-SER WS-V1 WS-V2 WS-V3 WS-LONG
     MOVE "acceptance guardian attack target" TO TL-CASE
     MOVE EN-TGT(1) TO TL-OBSERVED-N
     MOVE 7 TO TL-EXPECTED-N
     PERFORM CHECK-N
     MOVE "acceptance guardian a new target restarts the attack time" TO TL-CASE
     MOVE EN-RS(1) TO WS-DIFF
     PERFORM CHECK-SMALL
     MOVE 5 TO EN-RS(1)
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE WS-ROW WS-INDEX WS-SER WS-V1 WS-V2 WS-V3 WS-LONG
     MOVE "acceptance guardian the same target keeps the attack time" TO TL-CASE
     COMPUTE WS-DIFF = EN-RS(1) - 5
     PERFORM CHECK-SMALL
     MOVE 0 TO EN-RS(1)
*>   In water, moving, v 0.15 < 0.5: v = 4, spikes 0.8 x 0.75.
     MOVE 0.8 TO EN-TA(1)
     MOVE 0.15 TO EN-TS(1)
     MOVE 1 TO EN-TM(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance guardian moving tail speed 4" TO TL-CASE
     COMPUTE WS-DIFF = EN-TS(1) - 4
     PERFORM CHECK-SMALL
     MOVE "acceptance guardian tail animation adds the speed" TO TL-CASE
     COMPUTE WS-DIFF = EN-TM(1) - 5
     PERFORM CHECK-SMALL
     MOVE "acceptance guardian moving spikes move toward 0" TO TL-CASE
     COMPUTE WS-DIFF = EN-TA(1) - 0.6
     PERFORM CHECK-SMALL
     MOVE "acceptance guardian attack time grows with a target" TO TL-CASE
     COMPUTE WS-DIFF = EN-RS(1) - 1
     PERFORM CHECK-SMALL
*>   Moving, v 4 >= 0.5: v += (0.5 - v) x 0.1.
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance guardian moving tail speed eases to 0.5" TO TL-CASE
     COMPUTE WS-DIFF = EN-TS(1) - 3.65
     PERFORM CHECK-SMALL
*>   Not moving: v toward 0.125 by 0.2, spikes toward 1 by 0.06.
     MOVE 0 TO EN-X1(1)
     MOVE 1 TO EN-TS(1)
     MOVE 0 TO EN-TA(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance guardian resting tail speed" TO TL-CASE
     COMPUTE WS-DIFF = EN-TS(1) - 0.825
     PERFORM CHECK-SMALL
     MOVE "acceptance guardian resting spikes" TO TL-CASE
     COMPUTE WS-DIFF = EN-TA(1) - 0.06
     PERFORM CHECK-SMALL
*>   The attack time stops at the duration 80 (guardian) and 60 (elder).
     MOVE 80 TO EN-RS(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance guardian attack time stops at 80" TO TL-CASE
     COMPUTE WS-DIFF = EN-RS(1) - 80
     PERFORM CHECK-SMALL
     MOVE 0 TO EN-TGT(1)
     MOVE 10 TO EN-RS(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance guardian attack time stays without a target" TO TL-CASE
     COMPUTE WS-DIFF = EN-RS(1) - 10
     PERFORM CHECK-SMALL
*>   Out of water: v = 2, spikes a random float in 0 to 1, tail still advances.
     MOVE 80 TO EN-Y(1) EN-OY(1)
     MOVE 0 TO EN-TM(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance guardian out of water tail speed 2" TO TL-CASE
     COMPUTE WS-DIFF = EN-TS(1) - 2
     PERFORM CHECK-SMALL
     MOVE "acceptance guardian out of water spikes in range" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE 1 TO TL-OBSERVED-N
     IF EN-TA(1) >= 0 AND EN-TA(1) < 1
         MOVE 0 TO TL-OBSERVED-N
     END-IF
     PERFORM CHECK-N
*>   The elder guardian: duration 60.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "elder_guardian" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 3 TO EN-TGT(1)
     MOVE 60 TO EN-RS(1)
     MOVE 64 TO EN-Y(1) EN-OY(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance elder guardian attack time stops at 60" TO TL-CASE
     COMPUTE WS-DIFF = EN-RS(1) - 60
     PERFORM CHECK-SMALL
     MOVE 59 TO EN-RS(1)
     CALL "ENTITIES-ANIM-TICK" USING CLIENT-STATE
     MOVE "acceptance elder guardian attack time reaches 60" TO TL-CASE
     COMPUTE WS-DIFF = EN-RS(1) - 60
     PERFORM CHECK-SMALL
*>   Another mob ignores the entries.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "cow" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 17 TO WS-INDEX
     MOVE 1 TO WS-SER
     MOVE 7 TO WS-V1
     CALL "ENTITY-VARIANT-SET" USING CLIENT-STATE WS-ROW WS-INDEX WS-SER WS-V1 WS-V2 WS-V3 WS-LONG
     MOVE "acceptance cow has no attack target" TO TL-CASE
     MOVE EN-TGT(1) TO TL-OBSERVED-N
     MOVE 0 TO TL-EXPECTED-N
     PERFORM CHECK-N
*>   Drawn: the spikes in and out, the tail.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE "guardian" TO WS-KEY
     PERFORM SPAWN-ONE
     MOVE 1 TO EN-TA(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE WS-SUM2 TO WS-SUM1
     MOVE 0 TO EN-TA(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE "acceptance guardian drawn with the spikes in" TO TL-CASE
     COMPUTE WS-DIFF = WS-SUM2 - WS-SUM1
     PERFORM CHECK-OTHER
     MOVE WS-SUM2 TO WS-SUM1
     MOVE 1.5 TO EN-TM(1)
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     PERFORM SUM-MESH
     MOVE "acceptance guardian drawn with another tail animation" TO TL-CASE
     COMPUTE WS-DIFF = WS-SUM2 - WS-SUM1
     PERFORM CHECK-OTHER
     STOP RUN.
 SPAWN-ONE.
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE 1 TO WS-ID
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW.
 SUM-MESH.
     MOVE 0 TO WS-SUM2
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > RL-EN-COUNT
         COMPUTE WS-SUM2 = WS-SUM2 + (RL-EN-Y(WS-J) + RL-EN-X(WS-J) * 2 + RL-EN-Z(WS-J) * 3) * WS-J
     END-PERFORM.
 CHECK-SMALL.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF < 0.0001 AND WS-DIFF > -0.0001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CHECK-OTHER.
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-DIFF > 0.001 OR WS-DIFF < -0.001
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 CHECK-N.
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-GUARDIAN.

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
