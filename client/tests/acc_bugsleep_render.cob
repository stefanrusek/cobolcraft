*> Acceptance test, lane bugsleep (operator report of try19: "Villagers are invisible in beds", "no getting into the bed": the client shows no lying-down pose or view; docs/protocol/18 section 1.4
*> entries 6 and 14, 34-1 section 6.5 and 34-2 sections 2.1 and 2.2 (the sleeping pose of a model), 12 section 7.2 step 6 (the camera of a sleeping player), 53 pose SLEEPING).
*> A whole red bed (head half facing south) in the replica of the standard set; a villager row with pose SLEEPING (2) and the head half as its sleeping position (Set Entity Data entries 6 and 14):
*> the replica keeps both, and the model lies along the bed (vertex level, the real renderer): its vertices span more than 1.5 blocks along z and less than 1.2 across, all above the mattress top
*> (y 5.5625) and under 0.8 above it, inside the bed's footprint of the head half and the foot half; a standing villager of the same place stands 1.9 high. The own entity (the player): pose 2 and
*> the bed position put the player to sleep (PL-SLEEP), the camera is at the bed (yaw 180 for a bed facing south, pitch 0, the eye 0.2 above the mattress), pose 0 stands the player up again.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACC-BUGSLEEP-RENDER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-VILLAGER            BINARY-LONG.
 01 WS-BED-ID              BINARY-LONG.
 01 WS-ROW-AREA            PIC X(66).
 01 WS-BLOCK-ROW           PIC X(819).
 01 WS-STATUS              BINARY-LONG.
 01 WS-DEFAULT             BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-STATE-ID            BINARY-LONG.
 01 WS-BLOCK-ID            BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-BED-HEAD            BINARY-LONG.
 01 WS-BED-FOOT            BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-BX                  BINARY-LONG VALUE 3.
 01 WS-BY                  BINARY-LONG VALUE 5.
 01 WS-BZ                  BINARY-LONG VALUE 3.
 01 WS-HZ                  BINARY-LONG VALUE 4.
 01 WS-FIRST               BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-RANGE.
    05 WS-R                BINARY-LONG OCCURS 6 TIMES.
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CAM-TABLE.
    05 WS-CAM              FLOAT-LONG OCCURS 3 TIMES.
 01 WS-CYAW                FLOAT-LONG.
 01 WS-CPITCH              FLOAT-LONG.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-ZERO2               BINARY-LONG VALUE 0.
 01 WS-ROWNO               BINARY-LONG.
 01 WS-WY                  BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-SPAN-X              BINARY-LONG.
 01 WS-SPAN-Z              BINARY-LONG.
 01 WS-MOVE                BINARY-LONG.
 01 WS-POSE                BINARY-LONG.
 01 WS-PRESENT             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-PART                PIC X(8).
 01 WS-MATCH               PIC 9.
 01 WS-ONE-ROW             BINARY-LONG VALUE 1.
 01 WS-OPS.
    05 WS-OP               FLOAT-LONG OCCURS 64 TIMES.
 PROCEDURE DIVISION.
     CALL "CL-INIT" USING CLIENT-STATE
     MOVE 0 TO PK-COUNT
     CALL "ENTITY-ATLAS-BUILD" USING CLIENT-STATE
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 0 TO ST-READY
     CALL "STATE-TABLES-ENSURE" USING CLIENT-STATE
     MOVE 384 TO PL-HEIGHT
     MOVE -64 TO PL-MIN-Y
     MOVE 1 TO PL-HAS-SKY
     MOVE 0 TO SK-U PL-YAW
     MOVE 0 TO WS-EYE(1)
     MOVE 6 TO WS-EYE(2)
     MOVE 0 TO WS-EYE(3)
     MOVE "villager" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-VILLAGER WS-ROW-AREA WS-STATUS
     MOVE "red_bed" TO WS-KEY
     CALL "CONTENT-BLOCK-BY-KEY" USING WS-KEY WS-BED-ID WS-BLOCK-ROW WS-STATUS
     CALL "CONTENT-STATE-DEFAULT" USING WS-BED-ID WS-DEFAULT WS-STATUS
     MOVE 0 TO WS-BED-HEAD WS-BED-FOOT
     COMPUTE WS-S = WS-DEFAULT - 16
     PERFORM VARYING WS-S FROM WS-S BY 1 UNTIL WS-S > WS-DEFAULT + 16
         CALL "CONTENT-BLOCK-OF-STATE" USING WS-S WS-BLOCK-ID WS-INDEX WS-BLOCK-ROW WS-STATUS
         IF WS-STATUS = CT-OK AND WS-BLOCK-ID = WS-BED-ID
             MOVE "head" TO WS-PART
             CALL "BSL-IS" USING WS-S WS-PART WS-MATCH
             IF WS-MATCH = 1
                 MOVE WS-S TO WS-BED-HEAD
             END-IF
             MOVE "foot" TO WS-PART
             CALL "BSL-IS" USING WS-S WS-PART WS-MATCH
             IF WS-MATCH = 1
                 MOVE WS-S TO WS-BED-FOOT
             END-IF
         END-IF
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE "bugsleep render: the red bed has a head state and a foot state facing south, not occupied" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-BED-HEAD > 0 AND WS-BED-FOOT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The bed in the replica: foot at (3, 5, 3), head at (3, 5, 4), facing south.
     CALL "WORLD-CLEAR" USING CLIENT-STATE
     COMPUTE WS-WY = WS-BY
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-BX WS-WY WS-BZ WS-BED-FOOT
     CALL "TEST-SET-BLOCK" USING CLIENT-STATE WS-BX WS-WY WS-HZ WS-BED-HEAD

*>   A villager in the bed: pose 2 and the head half as its sleeping position.
     MOVE 7 TO WS-ID
     MOVE 3.5 TO WS-X
     MOVE 5.5625 TO WS-Y
     MOVE 4.5 TO WS-Z
     CALL "BSL-SPAWN" USING CLIENT-STATE WS-ID WS-VILLAGER WS-X WS-Y WS-Z
     MOVE 2 TO WS-POSE
     MOVE 1 TO WS-PRESENT
     CALL "BSL-DATA" USING CLIENT-STATE WS-ID WS-POSE WS-PRESENT WS-BX WS-BY WS-HZ
     MOVE "bugsleep render: the replica keeps the sleeping pose of the villager" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EN-POSE(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugsleep render: the replica keeps the villager's sleeping position (set, x, y, z)" TO TL-CASE
     MOVE 1354 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-BED-SET(1) * 1000 + EN-BED-X(1) * 100 + EN-BED-Y(1) * 10 + EN-BED-Z(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1 TO WS-FIRST
     MOVE RL-EN-COUNT TO WS-LAST
     CALL "BSL-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     MOVE "bugsleep render: the sleeping villager is drawn" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-COUNT > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   World y of the lowest and the highest vertex: the ranges are relative to the eye (0, 6, 0).
     COMPUTE WS-LOW = WS-R(3) + 6000
     COMPUTE WS-HIGH = WS-R(4) + 6000
     MOVE "bugsleep render: the sleeping villager lies in the bed (no vertex under the bed block, the hat brim on edge reaches 0.5 under the mattress top)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-LOW >= 5000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugsleep render: the sleeping villager lies flat (no vertex more than 0.8 above the mattress top)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HIGH <= 6362
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     COMPUTE WS-SPAN-X = WS-R(2) - WS-R(1)
     COMPUTE WS-SPAN-Z = WS-R(6) - WS-R(5)
     MOVE "bugsleep render: the sleeping villager lies along the bed (z span over 1.5 blocks, x span under 1.2)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-SPAN-Z > 1500 AND WS-SPAN-X < 1200
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugsleep render: the sleeping villager is inside the bed's footprint (x 2.9 to 4.1, z 2.5 to 5.5)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-R(1) >= 2900 AND WS-R(2) <= 4100 AND WS-R(5) >= 2500 AND WS-R(6) <= 5500
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The villager wakes: the standing pose, no sleeping position: it stands again (the model is 1.9 high).
     MOVE 0 TO WS-POSE
     MOVE 0 TO WS-PRESENT
     CALL "BSL-DATA" USING CLIENT-STATE WS-ID WS-POSE WS-PRESENT WS-ZERO WS-ZERO2 WS-N
     MOVE "bugsleep render: the pose of a woken villager is standing and the bed position is gone" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = EN-POSE(1) + EN-BED-SET(1)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE 1 TO WS-FIRST
     MOVE RL-EN-COUNT TO WS-LAST
     CALL "BSL-RANGE" USING CLIENT-STATE WS-FIRST WS-LAST WS-RANGE
     COMPUTE WS-HIGH = WS-R(4) + 6000
     MOVE "bugsleep render: a woken villager stands (its top is over 1.5 blocks above the bed's cell)" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-HIGH > 7000
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

*>   The own entity: pose 2 and the bed position put the player to sleep; the camera is at the bed.
     MOVE 99 TO PL-ENTITY-ID
     MOVE 3.5 TO PL-X
     MOVE 5.5625 TO PL-Y
     MOVE 4.5 TO PL-Z
     MOVE 40 TO PL-YAW
     MOVE 25 TO PL-PITCH
     MOVE 0 TO CL-CAMERA CL-CAM-SET
     MOVE 2 TO WS-POSE
     MOVE 1 TO WS-PRESENT
     MOVE 99 TO WS-ID
     CALL "BSL-DATA" USING CLIENT-STATE WS-ID WS-POSE WS-PRESENT WS-BX WS-BY WS-HZ
     MOVE "bugsleep render: pose 2 of the own entity puts the player to sleep" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE PL-SLEEP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugsleep render: the sleeping position of the own entity is the bed (x, y, z)" TO TL-CASE
     MOVE 354 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = PL-BED-X * 100 + PL-BED-Y * 10 + PL-BED-Z
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-CYAW WS-CPITCH WS-CAM-TABLE
     MOVE "bugsleep render: asleep the camera looks along the bed: yaw 180 for a bed facing south (12 section 7.2 step 6)" TO TL-CASE
     MOVE 180 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = FUNCTION MOD(WS-CYAW + 360, 360)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugsleep render: asleep the camera pitch is 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-CPITCH
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugsleep render: asleep the eye is 0.2 above the mattress (y 5.7625)" TO TL-CASE
     MOVE 5762 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-CAM(2) * 1000)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugsleep render: asleep the eye is over the middle of the head half, x 3.5" TO TL-CASE
     MOVE 3500 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-CAM(1) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "bugsleep render: asleep the eye is moved 0.15 along the view (z 4.35)" TO TL-CASE
     MOVE 4350 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N = FUNCTION INTEGER(WS-CAM(3) * 1000 + 0.5)
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Pose 0: the player stands up and the camera is the player's own again.
     MOVE 0 TO WS-POSE
     MOVE 0 TO WS-PRESENT
     CALL "BSL-DATA" USING CLIENT-STATE WS-ID WS-POSE WS-PRESENT WS-ZERO WS-ZERO2 WS-N
     MOVE "bugsleep render: pose 0 of the own entity wakes the player" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE PL-SLEEP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     CALL "CAMERA-PLACE" USING CLIENT-STATE WS-CYAW WS-CPITCH WS-CAM-TABLE
     MOVE "bugsleep render: awake the view is the player's own yaw (40)" TO TL-CASE
     MOVE 40 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-CYAW
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   The translate along the bed (34-2 2.1 step 0): -(standing eye height - 0.1) along the facing: the villager 1.62, the zombie family 1.74 and the piglins 1.79.
     MOVE "villager" TO EN-KEY(1)
     MOVE 3 TO EN-BED-X(1)
     MOVE 5 TO EN-BED-Y(1)
     MOVE 4 TO EN-BED-Z(1)
     CALL "ENTITY-SLEEP-SEQUENCE" USING CLIENT-STATE WS-ONE-ROW WS-OPS
     MOVE "bugsleep render: a sleeping villager is moved 1.52 toward the foot of a bed facing south (z -1.52)" TO TL-CASE
     MOVE -1520 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OP(5) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "zombie" TO EN-KEY(1)
     CALL "ENTITY-SLEEP-SEQUENCE" USING CLIENT-STATE WS-ONE-ROW WS-OPS
     MOVE "bugsleep render: a sleeping zombie is moved 1.64 toward the foot (eye height 1.74)" TO TL-CASE
     MOVE -1640 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OP(5) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "piglin" TO EN-KEY(1)
     CALL "ENTITY-SLEEP-SEQUENCE" USING CLIENT-STATE WS-ONE-ROW WS-OPS
     MOVE "bugsleep render: a sleeping piglin is moved 1.69 toward the foot (eye height 1.79)" TO TL-CASE
     MOVE -1690 TO TL-EXPECTED-N
     COMPUTE TL-OBSERVED-N ROUNDED = WS-OP(5) * 1000
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM ACC-BUGSLEEP-RENDER.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSL-IS.
*> USING state id, part text, match out: the state faces south, has that bed part and is not occupied.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STATUS              BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-FACING              PIC 9.
 01 WS-PARTOK              PIC 9.
 01 WS-FREE                PIC 9.
 01 WS-PROPS.
    05 WS-P-COUNT          BINARY-LONG.
    05 WS-P-ENTRY OCCURS 16 TIMES.
       10 WS-P-NAME        PIC X(24).
       10 WS-P-VALUE       PIC X(32).
 LINKAGE SECTION.
 01 L-STATE                BINARY-LONG.
 01 L-PART                 PIC X(8).
 01 L-MATCH                PIC 9.
 PROCEDURE DIVISION USING L-STATE L-PART L-MATCH.
     MOVE 0 TO WS-FACING WS-PARTOK WS-FREE L-MATCH
     CALL "CONTENT-STATE-PROPS" USING L-STATE WS-PROPS WS-STATUS
     PERFORM VARYING WS-P FROM 1 BY 1 UNTIL WS-P > WS-P-COUNT
         IF WS-P-NAME(WS-P) = "facing" AND WS-P-VALUE(WS-P) = "south"
             MOVE 1 TO WS-FACING
         END-IF
         IF WS-P-NAME(WS-P) = "part" AND WS-P-VALUE(WS-P) = L-PART
             MOVE 1 TO WS-PARTOK
         END-IF
         IF WS-P-NAME(WS-P) = "occupied" AND WS-P-VALUE(WS-P) = "false"
             MOVE 1 TO WS-FREE
         END-IF
     END-PERFORM
     IF WS-FACING = 1 AND WS-PARTOK = 1 AND WS-FREE = 1
         MOVE 1 TO L-MATCH
     END-IF
     GOBACK.
 END PROGRAM BSL-IS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSL-DATA.
*> USING CLIENT-STATE, entity id, pose, present (0 or 1), x, y, z: Set Entity Data with entry 6 (POSE) and entry 14 (OPTIONAL_BLOCK_POS, the sleeping position).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-DATA                BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-POSE                 BINARY-LONG.
 01 L-PRESENT              BINARY-LONG.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-POSE L-PRESENT L-X L-Y L-Z.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     INITIALIZE MD-METADATA-ENTRY
     MOVE 6 TO MD-MD-INDEX
     MOVE MD-MDS-POSE TO MD-MD-SERIALIZER
     MOVE L-POSE TO MD-MD-INT
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE 14 TO MD-MX-INDEX
     MOVE 11 TO MD-MX-SERIALIZER
     MOVE L-PRESENT TO MD-MX-PRESENT
     MOVE L-X TO MD-MX-POS-X
     MOVE L-Y TO MD-MX-POS-Y
     MOVE L-Z TO MD-MX-POS-Z
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     INITIALIZE MD-METADATA-ENTRY
     MOVE MD-MD-END TO MD-MD-INDEX
     CALL "PB-PUT-ENTITY-METADATA" USING PB-BUFFER MD-METADATA-ENTRY
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-DATA
     GOBACK.
 END PROGRAM BSL-DATA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSL-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG): Add Entity at rest.
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
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z.
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
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM BSL-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. BSL-RANGE.
*> USING CLIENT-STATE, first and last entity vertex, range out (BINARY-LONG x 6): min and max x, y, z in thousandths.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-FIRST                BINARY-LONG.
 01 L-LAST                 BINARY-LONG.
 01 L-RANGE.
    05 L-R                 BINARY-LONG OCCURS 6 TIMES.
 PROCEDURE DIVISION USING CLIENT-STATE L-FIRST L-LAST L-RANGE.
     MOVE 999999999 TO L-R(1) L-R(3) L-R(5)
     MOVE -999999999 TO L-R(2) L-R(4) L-R(6)
     PERFORM VARYING WS-I FROM L-FIRST BY 1 UNTIL WS-I > L-LAST
         COMPUTE WS-V = FUNCTION INTEGER(RL-EN-X(WS-I) * 1000 + 0.5)
         MOVE FUNCTION MIN(L-R(1), WS-V) TO L-R(1)
         MOVE FUNCTION MAX(L-R(2), WS-V) TO L-R(2)
         COMPUTE WS-V = FUNCTION INTEGER(RL-EN-Y(WS-I) * 1000 + 0.5)
         MOVE FUNCTION MIN(L-R(3), WS-V) TO L-R(3)
         MOVE FUNCTION MAX(L-R(4), WS-V) TO L-R(4)
         COMPUTE WS-V = FUNCTION INTEGER(RL-EN-Z(WS-I) * 1000 + 0.5)
         MOVE FUNCTION MIN(L-R(5), WS-V) TO L-R(5)
         MOVE FUNCTION MAX(L-R(6), WS-V) TO L-R(6)
     END-PERFORM
     GOBACK.
 END PROGRAM BSL-RANGE.

 COPY CLTEST.
