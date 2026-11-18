 *> Atlas slots of the entity models (CL-MODELS rows with texture codes, EA-MT, 64 of them): a full atlas evicts the slots least recently used, the slots of the
 *> mobs on screen are kept where they are and the atlas is not rebuilt for the mobs that are already in it.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-ATLAS-LRU.
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
 01 WS-I                   BINARY-LONG.
 01 WS-I-D                 PIC 9.
 01 WS-N                   BINARY-LONG.
 01 WS-S                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-K20                 PIC X(20).
 01 WS-PATH                PIC X(64).
 01 WS-RED                 FLOAT-LONG.
 01 WS-GREEN               FLOAT-LONG.
 01 WS-BLUE                FLOAT-LONG.
 01 WS-MODEL               BINARY-LONG.
 01 WS-INDEX               BINARY-LONG.
 01 WS-SERIAL              BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-INT2                BINARY-LONG.
 01 WS-INT3                BINARY-LONG.
 01 WS-LONG                BINARY-DOUBLE.
 01 WS-BASE-COUNT          BINARY-LONG.
 01 WS-F                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-BAD-COUNT           BINARY-LONG.
 01 WS-BAD-SEEN            BINARY-LONG.
 01 WS-BAD-DUP             BINARY-LONG.
 01 WS-BAD-MOVED           BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-PREV-TABLE.
    05 WS-PREV             BINARY-LONG OCCURS 64 TIMES.
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
*>   A full atlas of 64 slots (models 1 to 64): a pig (model 2) and a dolphin, a cod and a salmon are on screen. The pig keeps its slot, the three others take
*>   the slots of the models least recently used (the lowest indexes of equal age) instead of every slot being released.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 64
         MOVE WS-S TO EA-MT-MODEL(WS-S)
         MOVE 0 TO EA-MT-TEX(WS-S)
     END-PERFORM
     MOVE 64 TO EA-MT-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         EVALUATE WS-I
             WHEN 1 MOVE "pig" TO WS-KEY
             WHEN 2 MOVE "dolphin" TO WS-KEY
             WHEN 3 MOVE "cod" TO WS-KEY
             WHEN OTHER MOVE "salmon" TO WS-KEY
         END-EVALUATE
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
         MOVE WS-I TO WS-ID
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     END-PERFORM
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "N" TO TL-MODE
     MOVE "acceptance atlas lru the pig keeps its slot 2" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE EA-MT-MODEL(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance atlas lru the atlas is still full" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance atlas lru the dolphin took the slot of the oldest model" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF CL-MD-KEY(EA-MT-MODEL(1)) = "dolphin"
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-N
     PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > 64
         IF CL-MD-KEY(EA-MT-MODEL(WS-S)) = "cod" OR "salmon"
             ADD 1 TO WS-N
         END-IF
     END-PERFORM
     MOVE "acceptance atlas lru the cod and the salmon have a slot" TO TL-CASE
     MOVE 2 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance atlas lru the four mobs are meshed whole" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF RL-EN-COUNT >= 144 AND FUNCTION MOD(RL-EN-COUNT, 36) = 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   A second frame with the same mobs changes nothing: the slots stay where they are.
     MOVE EA-MT-MODEL(2) TO WS-MODEL
     MOVE EA-MT-MODEL(1) TO WS-CODE
     CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
     MOVE "acceptance atlas lru a second frame keeps slot 1" TO TL-CASE
     MOVE WS-CODE TO TL-EXPECTED-N
     MOVE EA-MT-MODEL(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance atlas lru a second frame keeps slot 2" TO TL-CASE
     MOVE WS-MODEL TO TL-EXPECTED-N
     MOVE EA-MT-MODEL(2) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Stress: 150 frames, each shows a window of 24 mobs of different models taken from the whole table (starting at another model every frame, so over the run far
*>   more than 64 models pass through the atlas). In every frame the atlas holds at most 64 slots without a pair twice, every mob on screen has its slot, and a
*>   frame repeated with the same mobs moves no slot.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     MOVE 0 TO EA-MT-COUNT
     MOVE 0 TO WS-BAD-COUNT WS-BAD-SEEN WS-BAD-DUP WS-BAD-MOVED
     PERFORM VARYING WS-F FROM 0 BY 1 UNTIL WS-F > 149
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE 0 TO WS-N
         MOVE 0 TO WS-W
         PERFORM UNTIL WS-N >= 24 OR WS-W >= CL-MODEL-COUNT
             COMPUTE WS-INDEX = FUNCTION MOD(WS-F * 7 + WS-W, CL-MODEL-COUNT) + 1
             ADD 1 TO WS-W
             MOVE SPACES TO WS-KEY
             MOVE CL-MD-KEY(WS-INDEX) TO WS-KEY
             CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
             IF WS-STATUS = 0
                 ADD 1 TO WS-N
                 MOVE WS-N TO WS-ID
                 CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
             END-IF
         END-PERFORM
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         IF EA-MT-COUNT > 64
             ADD 1 TO WS-BAD-COUNT
         END-IF
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > EN-COUNT
             MOVE 0 TO WS-SEEN
             IF EN-MODEL(WS-I) > 0 AND CL-MD-ANIM(EN-MODEL(WS-I)) NOT = "F"
                 PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
                     IF EA-MT-MODEL(WS-S) = EN-MODEL(WS-I)
                         MOVE 1 TO WS-SEEN
                     END-IF
                 END-PERFORM
                 IF WS-SEEN = 0
                     ADD 1 TO WS-BAD-SEEN
                 END-IF
             END-IF
         END-PERFORM
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
             PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J >= WS-S
                 IF EA-MT-MODEL(WS-J) = EA-MT-MODEL(WS-S) AND EA-MT-TEX(WS-J) = EA-MT-TEX(WS-S)
                     ADD 1 TO WS-BAD-DUP
                 END-IF
             END-PERFORM
             MOVE EA-MT-MODEL(WS-S) TO WS-PREV(WS-S)
         END-PERFORM
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
         PERFORM VARYING WS-S FROM 1 BY 1 UNTIL WS-S > EA-MT-COUNT
             IF WS-PREV(WS-S) NOT = EA-MT-MODEL(WS-S)
                 ADD 1 TO WS-BAD-MOVED
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE "N" TO TL-MODE
     MOVE 0 TO TL-EXPECTED-N
     MOVE "acceptance atlas lru stress: never more than 64 slots" TO TL-CASE
     MOVE WS-BAD-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance atlas lru stress: every mob on screen has its slot" TO TL-CASE
     MOVE WS-BAD-SEEN TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance atlas lru stress: no pair in two slots" TO TL-CASE
     MOVE WS-BAD-DUP TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance atlas lru stress: a repeated frame moves no slot" TO TL-CASE
     MOVE WS-BAD-MOVED TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE "acceptance atlas lru stress: the atlas ends full" TO TL-CASE
     MOVE 64 TO TL-EXPECTED-N
     MOVE EA-MT-COUNT TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.
 END PROGRAM TEST-ENTITY-ATLAS-LRU.

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

