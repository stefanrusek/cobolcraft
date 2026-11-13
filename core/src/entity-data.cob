*> Entity persistence (07 section 9.3): the entities/ region files, one payload per chunk (ENTITY-NBT-*, PERSIST-ENTITIES-*).
*> Split from persistence.cob (T0331).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-WRITE.
*> USING dimension row, chunk x, chunk z (BINARY-LONG), PB-BUFFER (appended to): the entities/ chunk
*> payload (07 §9.3) of that chunk: DataVersion, Position [chunk x, chunk z] and Entities, one
*> compound per mob and ground item of that dimension whose position is in the chunk, in tracker
*> order: id, Pos, Motion, Rotation, then Health (mobs) or Item {id, count} and Age (ground items).
*> Players are not stored here (07 §9.2).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-T-FLOAT             BINARY-LONG VALUE 5.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-POSITION.
    05 WS-POSITION-INT     BINARY-LONG OCCURS 2 TIMES.
 01 WS-ROW                 BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-PASS                BINARY-LONG.
 01 WS-FLOAT               FLOAT-SHORT.
 01 WS-NS-KEY              PIC X(64).
 01 WS-NS-LENGTH           BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-CX                   BINARY-LONG.
 01 L-CZ                   BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-CX L-CZ PB-BUFFER.
     MOVE 0 TO WS-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM
                 AND FUNCTION INTEGER(EN-X(WS-ROW) / 16) = L-CX
                 AND FUNCTION INTEGER(EN-Z(WS-ROW) / 16) = L-CZ
             ADD 1 TO WS-COUNT
         END-IF
     END-PERFORM
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     MOVE "Position" TO WN MOVE 8 TO WL
     MOVE L-CX TO WS-POSITION-INT(1)
     MOVE L-CZ TO WS-POSITION-INT(2)
     CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-TWO WS-POSITION
     MOVE "Entities" TO WN
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-COMPOUND WS-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM
                 AND FUNCTION INTEGER(EN-X(WS-ROW) / 16) = L-CX
                 AND FUNCTION INTEGER(EN-Z(WS-ROW) / 16) = L-CZ
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
             MOVE "id" TO WN MOVE 2 TO WL
             COMPUTE WS-KIND = EN-TYPE(WS-ROW) + 1
             CALL "PERSIST-NAMESPACED" USING ET-KEY(WS-KIND) ET-KEY-LENGTH(WS-KIND)
                 WS-NS-KEY WS-NS-LENGTH
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
             MOVE "Pos" TO WN MOVE 3 TO WL
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-DOUBLE WS-THREE
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-X(WS-ROW)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-Y(WS-ROW)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-Z(WS-ROW)
             MOVE "Motion" TO WN MOVE 6 TO WL
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-DOUBLE WS-THREE
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-VX(WS-ROW)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-VY(WS-ROW)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WN WS-ELEMENT EN-VZ(WS-ROW)
             MOVE "Rotation" TO WN MOVE 8 TO WL
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-T-FLOAT WS-TWO
             CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WS-ELEMENT EN-YAW(WS-ROW)
             CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WS-ELEMENT EN-PITCH(WS-ROW)
             IF EN-TYPE(WS-ROW) = CR-LOOSE-ITEM
                 MOVE "Item" TO WN MOVE 4 TO WL
                 CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
                 MOVE "id" TO WN MOVE 2 TO WL
                 COMPUTE WS-KIND = EN-ITEM(WS-ROW) + 1
                 CALL "PERSIST-NAMESPACED" USING IT-KEY(WS-KIND) IT-KEY-LENGTH(WS-KIND)
                     WS-NS-KEY WS-NS-LENGTH
                 CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL WS-NS-KEY WS-NS-LENGTH
                 MOVE "count" TO WN MOVE 5 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-ITEM-COUNT(WS-ROW)
                 CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
                 MOVE "Age" TO WN MOVE 3 TO WL
                 CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL EN-AGE(WS-ROW)
             ELSE
                 MOVE "Health" TO WN MOVE 6 TO WL
                 MOVE EN-HEALTH(WS-ROW) TO WS-FLOAT
                 CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WN WL WS-FLOAT
             END-IF
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-IF
     END-PERFORM
     CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     GOBACK.
 END PROGRAM ENTITY-NBT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-READ.
*> USING dimension row (BINARY-LONG), PB-BUFFER (an entities/ chunk payload at PB-POS), outcome out
*> (BINARY-LONG: 0 read, 1 malformed): every entity of its Entities list enters that dimension
*> (ENTITY-NBT-ONE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM PB-BUFFER L-OUTCOME.
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         IF WN = "Entities" AND WS-TYPE = 9
             CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                 CALL "ENTITY-NBT-ONE" USING L-DIM PB-BUFFER
             END-PERFORM
         ELSE
             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-IF
     END-PERFORM
     MOVE PB-ERROR TO L-OUTCOME
     GOBACK.
 END PROGRAM ENTITY-NBT-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ENTITY-NBT-ONE.
*> USING dimension row, PB-BUFFER (an entity compound payload at PB-POS, 07 §9.3): a ground item
*> (GI-SPAWN with its stack, position and motion, no pickup delay, then its Age and rotation) or a
*> mob (MOB-SPAWN with its type, position and yaw, then its health, pitch and vertical motion). An
*> entity of another type, or a malformed one, is not created.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY CITEMS.
 COPY MOBS.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-KEY                 PIC X(64).
 01 WS-LOCAL               PIC X(48).
 01 WS-KEY-CAPACITY        BINARY-LONG VALUE 64.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-ENTITY-TYPE         BINARY-LONG.
 01 WS-ITEM                BINARY-LONG.
 01 WS-ITEM-COUNT          BINARY-LONG.
 01 WS-AGE                 BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-PITCH               FLOAT-SHORT.
 01 WS-HEALTH              FLOAT-SHORT.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM PB-BUFFER.
     MOVE -1 TO WS-ENTITY-TYPE
     MOVE 0 TO WS-ITEM WS-ITEM-COUNT WS-AGE WS-DELAY WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ
     MOVE 0 TO WS-YAW WS-PITCH WS-HEALTH
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "id" AND WS-TYPE = 8
                 MOVE SPACES TO WS-KEY
                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY WS-KEY-LENGTH
                 CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > ET-COUNT
                     IF ET-KEY(WS-I) = WS-LOCAL
                         COMPUTE WS-ENTITY-TYPE = WS-I - 1
                     END-IF
                 END-PERFORM
             WHEN WN = "Pos" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-X
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Y
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-Z
             WHEN WN = "Motion" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-VX
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-VY
                 CALL "PB-GET-DOUBLE" USING PB-BUFFER WS-VZ
             WHEN WN = "Rotation" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-YAW
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-PITCH
             WHEN WN = "Health" AND WS-TYPE = 5
                 CALL "PB-GET-FLOAT" USING PB-BUFFER WS-HEALTH
             WHEN WN = "Age" AND WS-TYPE = 3
                 CALL "PB-GET-INT" USING PB-BUFFER WS-AGE
             WHEN WN = "Item" AND WS-TYPE = 10
                 PERFORM UNTIL PB-ERROR = 1
                     MOVE SPACES TO WN
                     CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN WS-CAPACITY
                         WL
                     IF WS-INNER-TYPE = 0
                         EXIT PERFORM
                     END-IF
                     EVALUATE TRUE
                         WHEN WN = "id" AND WS-INNER-TYPE = 8
                             MOVE SPACES TO WS-KEY
                             CALL "NBT-READ-STRING" USING PB-BUFFER WS-KEY WS-KEY-CAPACITY
                                 WS-KEY-LENGTH
                             CALL "PERSIST-LOCAL-KEY" USING WS-KEY WS-LOCAL
                             PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > IT-COUNT
                                 IF IT-KEY(WS-I) = WS-LOCAL
                                     COMPUTE WS-ITEM = WS-I - 1
                                 END-IF
                             END-PERFORM
                         WHEN WN = "count" AND WS-INNER-TYPE = 3
                             CALL "PB-GET-INT" USING PB-BUFFER WS-ITEM-COUNT
                         WHEN OTHER
                             CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                     END-EVALUATE
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     EVALUATE TRUE
         WHEN PB-ERROR = 1
             CONTINUE
         WHEN WS-ENTITY-TYPE = CR-LOOSE-ITEM
             CALL "GI-SPAWN" USING L-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-ITEM-COUNT
                 WS-DELAY WS-ROW
             MOVE WS-AGE TO EN-AGE(WS-ROW)
             MOVE WS-YAW TO EN-YAW(WS-ROW)
             MOVE WS-PITCH TO EN-PITCH(WS-ROW)
         WHEN WS-ENTITY-TYPE >= MOB-FIRST-TYPE
             CALL "MOB-SPAWN" USING L-DIM WS-ENTITY-TYPE WS-X WS-Y WS-Z WS-YAW WS-ROW
             COMPUTE EN-HEALTH(WS-ROW) ROUNDED = WS-HEALTH
             MOVE WS-PITCH TO EN-PITCH(WS-ROW)
             MOVE WS-VY TO EN-VY(WS-ROW)
     END-EVALUATE
     GOBACK.
 END PROGRAM ENTITY-NBT-ONE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-ENTITIES-SAVE.
*> USING dimension row: replaces the dimension's entities/ region files: every region file there is
*> deleted, then each chunk that holds mobs or ground items gets its payload (ENTITY-NBT-WRITE). A
*> chunk whose entities all left or vanished therefore holds none after the save.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ENTITIES            PIC X(8) VALUE "entities".
 01 WS-DIR                 PIC X(1024).
 01 WS-DIRZ                PIC X(1025).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-LIST                PIC X(65536).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-I                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-CHUNKS.
    05 WS-CHUNK OCCURS 1024 TIMES.
       10 WS-CHUNK-X       BINARY-LONG.
       10 WS-CHUNK-Z       BINARY-LONG.
 01 WS-CHUNK-COUNT         BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-DIM-DIR" USING L-DIM WS-ENTITIES WS-DIR WS-LENGTH
     MOVE LOW-VALUES TO WS-DIRZ
     MOVE WS-DIR(1:WS-LENGTH) TO WS-DIRZ(1:WS-LENGTH)
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     MOVE 1 TO WS-PTR
     PERFORM WS-LIST-COUNT TIMES
         MOVE SPACES TO WS-ENTRY
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY WITH POINTER WS-PTR
         MOVE SPACES TO WS-PATH
         STRING WS-DIR(1:WS-LENGTH) "/" WS-ENTRY(2:255) DELIMITED BY SIZE INTO WS-PATH
         CALL "CBL_DELETE_FILE" USING WS-PATH
     END-PERFORM
     MOVE 0 TO RETURN-CODE
*>   The distinct chunks that hold this dimension's mobs and ground items.
     MOVE 0 TO WS-CHUNK-COUNT
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND EN-DIM(WS-ROW) = L-DIM
             COMPUTE WS-CX = FUNCTION INTEGER(EN-X(WS-ROW) / 16)
             COMPUTE WS-CZ = FUNCTION INTEGER(EN-Z(WS-ROW) / 16)
             MOVE 0 TO WS-SEEN
             PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CHUNK-COUNT
                 IF WS-CHUNK-X(WS-K) = WS-CX AND WS-CHUNK-Z(WS-K) = WS-CZ
                     MOVE 1 TO WS-SEEN
                 END-IF
             END-PERFORM
             IF WS-SEEN = 0
                 ADD 1 TO WS-CHUNK-COUNT
                 MOVE WS-CX TO WS-CHUNK-X(WS-CHUNK-COUNT)
                 MOVE WS-CZ TO WS-CHUNK-Z(WS-CHUNK-COUNT)
             END-IF
         END-IF
     END-PERFORM
     MOVE WS-DIR TO WS-PATH
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > WS-CHUNK-COUNT
         CALL "PB-RESET" USING PB-BUFFER
         CALL "ENTITY-NBT-WRITE" USING L-DIM WS-CHUNK-X(WS-K) WS-CHUNK-Z(WS-K) PB-BUFFER
         CALL "REGION-WRITE" USING WS-DIR WS-LENGTH WS-CHUNK-X(WS-K) WS-CHUNK-Z(WS-K) PB-BUFFER
             WS-OUTCOME
         CALL "PERSIST-WRITE-CHECK" USING WS-OUTCOME WS-PATH WS-LENGTH
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-ENTITIES-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-ENTITIES-LOAD.
*> USING dimension row: every chunk payload of every entities/ region file of the dimension
*> (r.<rx>.<rz>.mca, 32 x 32 chunks each) enters the world (ENTITY-NBT-READ). The entity tracker
*> holds every entity of the world, so they are all loaded when the world opens.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-ENTITIES            PIC X(8) VALUE "entities".
 01 WS-DIR                 PIC X(1024).
 01 WS-DIRZ                PIC X(1025).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-LIST                PIC X(65536).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-PARTS.
    05 WS-PART             PIC X(32) OCCURS 4 TIMES.
 01 WS-ABS-X               BINARY-LONG.
 01 WS-ABS-Z               BINARY-LONG.
 01 WS-RX                  BINARY-LONG.
 01 WS-RZ                  BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PERSIST-DIM-DIR" USING L-DIM WS-ENTITIES WS-DIR WS-LENGTH
     MOVE LOW-VALUES TO WS-DIRZ
     MOVE WS-DIR(1:WS-LENGTH) TO WS-DIRZ(1:WS-LENGTH)
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     MOVE 1 TO WS-PTR
     PERFORM WS-LIST-COUNT TIMES
         MOVE SPACES TO WS-ENTRY WS-PART(1) WS-PART(2) WS-PART(3) WS-PART(4)
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY WITH POINTER WS-PTR
         UNSTRING WS-ENTRY(2:255) DELIMITED BY "." INTO WS-PART(1) WS-PART(2) WS-PART(3)
             WS-PART(4)
         COMPUTE WS-RX = FUNCTION NUMVAL(WS-PART(2))
         COMPUTE WS-RZ = FUNCTION NUMVAL(WS-PART(3))
         PERFORM VARYING WS-CZ FROM 0 BY 1 UNTIL WS-CZ > 31
             PERFORM VARYING WS-CX FROM 0 BY 1 UNTIL WS-CX > 31
                 COMPUTE WS-ABS-X = WS-RX * 32 + WS-CX
                 COMPUTE WS-ABS-Z = WS-RZ * 32 + WS-CZ
                 CALL "REGION-READ" USING WS-DIR WS-LENGTH WS-ABS-X WS-ABS-Z PB-BUFFER WS-OUTCOME
                 IF WS-OUTCOME = 0
                     CALL "ENTITY-NBT-READ" USING L-DIM PB-BUFFER WS-OUTCOME
                 END-IF
             END-PERFORM
         END-PERFORM
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-ENTITIES-LOAD.
