*> T10410 (bug-sweep: limbs textured upside down): the texture orientation of every cuboid the render path draws. The side faces (west, north, east, south)
*> of a cuboid show the texture upright: of two vertices of the same face, the one higher in the world has the smaller v (the top row of the face's
*> texture rectangle is the top of the face), at every cuboid of a zombie, a skeleton, an iron golem, a creeper and an enderman standing still (models whose parts are not
*> turned onto their side: every limb is checked, the left arms and legs are the mirrored cuboids). The bottom face (DOWN of the model, the visible top, face 0) and the top face keep their own order (checked by the head).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-UV.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY TESTLIB.
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-ID                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-BAD                 BINARY-LONG.
 01 WS-CUBES               BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-FD                  PIC 9.
 01 WS-V0                  BINARY-LONG.
 01 WS-HI                  BINARY-LONG.
 01 WS-LO                  BINARY-LONG.
 01 WS-LIST                PIC X(200).
 01 WS-PTR                 BINARY-LONG.
 01 WS-EDIT                PIC Z(5)9.
 01 WS-NAMES.
    05 FILLER              PIC X(12) VALUE "zombie".
    05 FILLER              PIC X(12) VALUE "skeleton".
    05 FILLER              PIC X(12) VALUE "iron_golem".
    05 FILLER              PIC X(12) VALUE "creeper".
    05 FILLER              PIC X(12) VALUE "enderman".
 01 WS-NAMES-R REDEFINES WS-NAMES.
    05 WS-NAME             PIC X(12) OCCURS 5 TIMES.
 01 WS-N                   BINARY-LONG.
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
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > 5
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE SPACES TO WS-KEY
         MOVE WS-NAME(WS-N) TO WS-KEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE 5 TO WS-ID
         MOVE 10.5 TO WS-X
         MOVE 64 TO WS-Y
         MOVE 10.5 TO WS-Z
         MOVE 0 TO WS-YAW
         CALL "ETM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         MOVE 0 TO RL-EN-COUNT
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         COMPUTE WS-CUBES = RL-EN-COUNT / 36
         MOVE 0 TO WS-BAD
         MOVE SPACES TO WS-LIST
         MOVE 1 TO WS-PTR
         PERFORM VARYING WS-C FROM 1 BY 1 UNTIL WS-C > WS-CUBES
             PERFORM VARYING WS-F FROM 2 BY 1 UNTIL WS-F > 5
                 COMPUTE WS-V0 = (WS-C - 1) * 36 + WS-F * 6
                 COMPUTE WS-HI = WS-V0 + 1
                 MOVE WS-HI TO WS-LO
                 PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 6
                     IF RL-EN-Y(WS-V0 + WS-K) > RL-EN-Y(WS-HI)
                         COMPUTE WS-HI = WS-V0 + WS-K
                     END-IF
                     IF RL-EN-Y(WS-V0 + WS-K) < RL-EN-Y(WS-LO)
                         COMPUTE WS-LO = WS-V0 + WS-K
                     END-IF
                 END-PERFORM
                 IF RL-EN-Y(WS-HI) - RL-EN-Y(WS-LO) > 0.001
                     IF RL-EN-V(WS-HI) NOT < RL-EN-V(WS-LO)
                         ADD 1 TO WS-BAD
                         MOVE WS-C TO WS-EDIT
                         MOVE WS-F TO WS-FD
                         STRING FUNCTION TRIM(WS-EDIT) "/" WS-FD " " DELIMITED BY SIZE INTO WS-LIST WITH POINTER WS-PTR
                     END-IF
                 END-IF
             END-PERFORM
         END-PERFORM
         MOVE "T" TO TL-MODE
         MOVE SPACES TO TL-CASE
         STRING "entity uv the side faces of every cuboid of a standing " FUNCTION TRIM(WS-NAME(WS-N))
             " show the texture upright" DELIMITED BY SIZE INTO TL-CASE
         MOVE SPACES TO TL-EXPECTED
         MOVE SPACES TO TL-OBSERVED
         MOVE "none" TO TL-EXPECTED
         IF WS-CUBES = 0
             MOVE "no cuboids" TO TL-OBSERVED
         ELSE
             IF WS-BAD = 0
                 MOVE "none" TO TL-OBSERVED
             ELSE
                 MOVE WS-LIST TO TL-OBSERVED
             END-IF
         END-IF
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     STOP RUN.
 END PROGRAM TEST-ENTITY-UV.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ETM-SPAWN.
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
 END PROGRAM ETM-SPAWN.
