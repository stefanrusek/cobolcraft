*> Cost test of lane bugsmooth (T60710; the lane perfframe measured the entity mesh at 70 mobs): the frames between ticks put every moving figure at its lerped position
*> (SMOOTH-ENTITIES around ENTITIES-MESH). The mean CPU time (C clock()) of a frame's entity mesh with 70 mobs within 40 blocks is shown (DISPLAY "BENCH ...") for
*> three cases: standing mobs (old = current: the baked meshes and the offset cache are reused), mobs walking a tenth of a block a tick and turning (position moves
*> every frame: only the offset to the eye changes, the baked model is reused), and mobs turning every frame (the baked model is baked again for the row whose yaw
*> changes: the cost the interpolation of the yaw adds, bounded by the number of mobs turning). Each must stay below a generous bound.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-SMOOTH-BENCH.
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
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPES.
    05 WS-TYPE             BINARY-LONG OCCURS 4 TIMES.
 01 WS-NAMES.
    05 FILLER PIC X(24) VALUE "zombie".
    05 FILLER PIC X(24) VALUE "creeper".
    05 FILLER PIC X(24) VALUE "skeleton".
    05 FILLER PIC X(24) VALUE "spider".
 01 WS-NAME-TABLE REDEFINES WS-NAMES.
    05 WS-KEY-NAME         PIC X(24) OCCURS 4 TIMES.
 01 WS-T                   BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-ANGLE               FLOAT-LONG.
 01 WS-DISTANCE            FLOAT-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-CASE                BINARY-LONG.
 01 WS-MODE                BINARY-LONG.
 01 WS-FRAMES              BINARY-LONG VALUE 100.
 01 WS-C0                  BINARY-DOUBLE.
 01 WS-C1                  BINARY-DOUBLE.
 01 WS-CPU-MS              FLOAT-LONG.
 01 WS-CPU-TEXT            PIC -(5)9.99.
 01 WS-COUNT               BINARY-LONG.
 01 WS-BOUND               BINARY-LONG.
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
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         MOVE SPACES TO WS-KEY
         MOVE WS-KEY-NAME(WS-I) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE(WS-I) WS-ROW-AREA WS-STATUS
     END-PERFORM
     MOVE 64 TO WS-Y
     PERFORM VARYING WS-I FROM 0 BY 1 UNTIL WS-I > 69
         COMPUTE WS-ID = 100 + WS-I
         COMPUTE WS-ANGLE = WS-I * 2.399963
         COMPUTE WS-DISTANCE = 8 + FUNCTION MOD(WS-I * 7, 33)
         COMPUTE WS-X = 10 + WS-DISTANCE * FUNCTION COS(WS-ANGLE)
         COMPUTE WS-Z = 10 + WS-DISTANCE * FUNCTION SIN(WS-ANGLE)
         COMPUTE WS-T = FUNCTION MOD(WS-I, 4) + 1
         COMPUTE WS-YAW = FUNCTION MOD(WS-I * 37, 360)
         CALL "SMB-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE(WS-T) WS-X WS-Y WS-Z WS-YAW
     END-PERFORM
     MOVE 1 TO CL-INTERP
     MOVE 1 TO WS-MODE
     MOVE 0 TO WS-CASE
     PERFORM 3 TIMES
         ADD 1 TO WS-CASE
         PERFORM SET-OLD
         CALL "SMOOTH-ENTITIES" USING CLIENT-STATE WS-MODE
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         PERFORM LEAVE-ROWS
         CALL STATIC "clock" RETURNING WS-C0
         PERFORM VARYING WS-F FROM 1 BY 1 UNTIL WS-F > WS-FRAMES
             COMPUTE CL-PARTIAL = FUNCTION MOD(WS-F, 3) / 3
             CALL "SMOOTH-ENTITIES" USING CLIENT-STATE WS-MODE
             CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
             PERFORM LEAVE-ROWS
         END-PERFORM
         CALL STATIC "clock" RETURNING WS-C1
         COMPUTE WS-CPU-MS = (WS-C1 - WS-C0) / 1000 / WS-FRAMES
         MOVE WS-CPU-MS TO WS-CPU-TEXT
         EVALUATE WS-CASE
             WHEN 1
                 DISPLAY "BENCH smooth entity mesh CPU ms per frame (70 mobs standing, partial 0..2/3): " WS-CPU-TEXT
             WHEN 2
                 DISPLAY "BENCH smooth entity mesh CPU ms per frame (70 mobs walking 0.1 a tick): " WS-CPU-TEXT
             WHEN OTHER
                 DISPLAY "BENCH smooth entity mesh CPU ms per frame (70 mobs turning 20 degrees a tick): " WS-CPU-TEXT
         END-EVALUATE
         COMPUTE WS-COUNT = WS-CPU-MS
         MOVE "N" TO TL-MODE
         MOVE 40 TO WS-BOUND
         IF WS-CASE = 3
             MOVE 150 TO WS-BOUND
         END-IF
         MOVE "test smooth bench: the entity mesh of 70 mobs with the interpolated state costs less than 40 ms of CPU a frame (150 ms when all 70 turn at once)" TO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE 0 TO TL-OBSERVED-N
         IF WS-COUNT < WS-BOUND
             MOVE 1 TO TL-OBSERVED-N
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.

*> Case 1 old = current (standing); case 2 the old position 0.1 behind; case 3 the old yaw 20 degrees behind.
 SET-OLD.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
         MOVE EN-X(WS-I) TO EN-OX(WS-I)
         MOVE EN-Y(WS-I) TO EN-OY(WS-I)
         MOVE EN-Z(WS-I) TO EN-OZ(WS-I)
         MOVE EN-YAW(WS-I) TO EN-OYAW(WS-I)
         MOVE EN-PITCH(WS-I) TO EN-OPITCH(WS-I)
         MOVE EN-HEAD-YAW(WS-I) TO EN-OHEAD(WS-I)
         IF WS-CASE = 2
             COMPUTE EN-OX(WS-I) = EN-X(WS-I) - 0.1
         END-IF
         IF WS-CASE = 3
             COMPUTE EN-OYAW(WS-I) = EN-YAW(WS-I) - 20
             COMPUTE EN-OHEAD(WS-I) = EN-HEAD-YAW(WS-I) - 20
         END-IF
     END-PERFORM.

 LEAVE-ROWS.
     MOVE 0 TO WS-MODE
     CALL "SMOOTH-ENTITIES" USING CLIENT-STATE WS-MODE
     MOVE 1 TO WS-MODE.
 END PROGRAM TEST-SMOOTH-BENCH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SMB-SPAWN.
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
 END PROGRAM SMB-SPAWN.

 COPY CLTEST.
