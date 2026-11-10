*> Implementation test of entity storage (core/src/persistence.cob ENTITY-NBT-WRITE and ENTITY-NBT-READ;
*> docs/protocol/07-nbt-and-anvil.md §9.3, §8): the entity chunk payload of one chunk of one
*> dimension holds DataVersion, Position [chunk x, chunk z] and one compound per mob and ground item
*> in that chunk (players and other chunks' entities left out), with the keys of §9.3; reading it
*> back puts the same mobs (type, position, motion, rotation, health) and ground items (item, count,
*> position, motion and the Age that gives the remaining despawn time) into that dimension.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-NBT.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY COREAPI.
 COPY DIMENSIONS.
 COPY ETIDS.
 COPY RULES.
 COPY CITEMPHYS.
 COPY PROTO.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-NAME                PIC X(16) VALUE "Alice".
 01 WS-NAME-LENGTH         BINARY-LONG VALUE 5.
 01 WS-ALICE               BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-VX                  FLOAT-LONG.
 01 WS-VY                  FLOAT-LONG.
 01 WS-VZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT.
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-DELAY               BINARY-LONG.
 01 WS-MOB                 BINARY-LONG.
 01 WS-GROUND              BINARY-LONG.
 01 WS-FAR                 BINARY-LONG.
 01 WS-SUB                 BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-ROOT                BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-ROOT-TYPE           BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-PATH                PIC X(128).
 01 WS-TEXT                PIC X(8192).
 01 WS-OBSERVED            PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-FEDIT               PIC -(5)9.999.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     MOVE 1 TO CS-EXTRA-DIMENSIONS
     MOVE 0 TO CS-HOSTILE-MOBS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "TEST-JOIN" USING WS-NAME WS-NAME-LENGTH WS-ALICE

*>   In chunk (1, 2) of cobolcraft:main (x 16 to 31, z 32 to 47): a sodgrazer and a ground item.
*>   Outside it: an abend in chunk (6, 6) and a ground item in cobolcraft:subroutine's chunk (1, 2).
     MOVE DIM-MAIN TO WS-DIM
     MOVE ET-SODGRAZER TO WS-TYPE
     MOVE 20.5 TO WS-X MOVE 55 TO WS-Y MOVE 37.25 TO WS-Z
     MOVE 90 TO WS-YAW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-MOB
     MOVE 5 TO EN-HEALTH(WS-MOB)
     MOVE -0.25 TO EN-VY(WS-MOB)
     MOVE 21 TO WS-X MOVE 56 TO WS-Y MOVE 38 TO WS-Z
     MOVE 0.125 TO WS-VX MOVE 0.25 TO WS-VY MOVE -0.375 TO WS-VZ
     MOVE 3 TO WS-ITEM
     MOVE 7 TO WS-COUNT
     MOVE 10 TO WS-DELAY
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY
         WS-GROUND
     MOVE 1200 TO EN-AGE(WS-GROUND)
*>   A new item has a random yaw (41 section 1); the saved Rotation is what it is, so the test fixes it.
     MOVE 0 TO EN-YAW(WS-GROUND)
     MOVE ET-ABEND TO WS-TYPE
     MOVE 100 TO WS-X WS-Z
     MOVE 0 TO WS-YAW
     CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-X WS-Y WS-Z WS-YAW WS-FAR
     MOVE DIM-SUBROUTINE TO WS-DIM
     MOVE 17.5 TO WS-X MOVE 40 TO WS-Y MOVE 33.5 TO WS-Z
     MOVE 0 TO WS-VX WS-VY WS-VZ
     MOVE 17 TO WS-ITEM
     MOVE 64 TO WS-COUNT
     MOVE 0 TO WS-DELAY
     CALL "GI-SPAWN" USING WS-DIM WS-X WS-Y WS-Z WS-VX WS-VY WS-VZ WS-ITEM WS-COUNT WS-DELAY
         WS-SUB
     MOVE 4000 TO EN-AGE(WS-SUB)
     MOVE 0 TO EN-YAW(WS-SUB)

     MOVE DIM-MAIN TO WS-DIM
     MOVE 1 TO WS-CX
     MOVE 2 TO WS-CZ
     PERFORM WRITE-ENTITIES
     MOVE "test entity nbt payload of cobolcraft:main chunk (1, 2): DataVersion 5023, Position "
         & "I[1,2], the sodgrazer and the ground item (no player, no other chunk or dimension)"
         TO TL-CASE
     MOVE SPACES TO WS-OBSERVED
     MOVE "DataVersion" TO WS-PATH PERFORM ADD-GET
     MOVE "Position" TO WS-PATH PERFORM ADD-GET
     MOVE "Entities" TO WS-PATH PERFORM ADD-GET
     MOVE "5023 I[1,2] [{id:cobolcraft:sodgrazer,Pos:[20.500,55.000,37.250],Motion:[0.000,-0.250,"
         & "0.000],Rotation:[90.000,0.000],Health:5.000},{id:cobolcraft:loose_item,Pos:[21.000,"
         & "56.000,38.000],Motion:[0.125,0.250,-0.375],Rotation:[0.000,0.000],Item:{id:cobolcraft:"
         & "loam,count:7},Age:1200}]" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test entity nbt read back: the same sodgrazer (type, position, yaw, health, vertical "
         & "motion) and ground item (item, count, position, motion, Age 1200 = 4800 ticks left) in "
         & "cobolcraft:main" TO TL-CASE
     CALL "ENTITY-REMOVE" USING WS-MOB
     CALL "ENTITY-REMOVE" USING WS-GROUND
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE SPACES TO WS-OBSERVED
     MOVE WS-OUTCOME TO WS-EDIT
     STRING "outcome " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-OBSERVED
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-PLAYER(WS-ROW) = 0 AND WS-ROW NOT = WS-FAR
                 AND WS-ROW NOT = WS-SUB
             PERFORM DESCRIBE-ENTITY
         END-IF
     END-PERFORM
     MOVE "outcome 0 | type 2 dim 1 at 20.500 55.000 37.250 yaw 90.000 health 5 vy -0.250 | "
         & "type 1 dim 1 at 21.000 56.000 38.000 v 0.125 0.250 -0.375 item 3x7 left 4800"
         TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test entity nbt cobolcraft:subroutine chunk (1, 2) holds only its ground item, which "
         & "reads back into cobolcraft:subroutine" TO TL-CASE
     MOVE DIM-SUBROUTINE TO WS-DIM
     PERFORM WRITE-ENTITIES
     MOVE SPACES TO WS-OBSERVED
     MOVE "Entities" TO WS-PATH PERFORM ADD-GET
     CALL "ENTITY-REMOVE" USING WS-SUB
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > EN-COUNT
         IF EN-USED(WS-ROW) = 1 AND EN-DIM(WS-ROW) = DIM-SUBROUTINE
             PERFORM DESCRIBE-ENTITY
         END-IF
     END-PERFORM
     MOVE "[{id:cobolcraft:loose_item,Pos:[17.500,40.000,33.500],Motion:[0.000,0.000,0.000],"
         & "Rotation:[0.000,0.000],Item:{id:cobolcraft:slag,count:64},Age:4000}] | type 1 dim 2 "
         & "at 17.500 40.000 33.500 v 0.000 0.000 0.000 item 17x64 left 2000" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test entity nbt a chunk without entities has an empty Entities list" TO TL-CASE
     MOVE DIM-MAIN TO WS-DIM
     MOVE 50 TO WS-CX
     PERFORM WRITE-ENTITIES
     MOVE SPACES TO WS-OBSERVED
     MOVE "Position" TO WS-PATH PERFORM ADD-GET
     MOVE "Entities" TO WS-PATH PERFORM ADD-GET
     MOVE "I[50,2] []" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test entity nbt a truncated payload reads as malformed (outcome 1)" TO TL-CASE
     MOVE 6 TO WS-CX WS-CZ
     PERFORM WRITE-ENTITIES
     SUBTRACT 10 FROM PB-LENGTH
     MOVE 0 TO PB-POS
     CALL "ENTITY-NBT-READ" USING WS-DIM PB-BUFFER WS-OUTCOME
     MOVE "N" TO TL-MODE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 WRITE-ENTITIES.
     CALL "PB-RESET" USING PB-BUFFER
     CALL "ENTITY-NBT-WRITE" USING WS-DIM WS-CX WS-CZ PB-BUFFER
     MOVE 0 TO PB-POS
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-ROOT-TYPE
     MOVE PB-POS TO WS-ROOT.

 DESCRIBE-ENTITY.
     MOVE EN-TYPE(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " | type " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
         INTO WS-OBSERVED
     MOVE EN-DIM(WS-ROW) TO WS-EDIT
     STRING FUNCTION TRIM(WS-OBSERVED) " dim " FUNCTION TRIM(WS-EDIT) " at" DELIMITED BY SIZE
         INTO WS-OBSERVED
     COMPUTE WS-FEDIT ROUNDED = EN-X(WS-ROW) PERFORM ADD-FEDIT
     COMPUTE WS-FEDIT ROUNDED = EN-Y(WS-ROW) PERFORM ADD-FEDIT
     COMPUTE WS-FEDIT ROUNDED = EN-Z(WS-ROW) PERFORM ADD-FEDIT
     IF EN-TYPE(WS-ROW) = ET-LOOSE-ITEM
         STRING FUNCTION TRIM(WS-OBSERVED) " v" DELIMITED BY SIZE INTO WS-OBSERVED
         COMPUTE WS-FEDIT ROUNDED = EN-VX(WS-ROW) PERFORM ADD-FEDIT
         COMPUTE WS-FEDIT ROUNDED = EN-VY(WS-ROW) PERFORM ADD-FEDIT
         COMPUTE WS-FEDIT ROUNDED = EN-VZ(WS-ROW) PERFORM ADD-FEDIT
         MOVE EN-ITEM(WS-ROW) TO WS-EDIT
         STRING FUNCTION TRIM(WS-OBSERVED) " item " FUNCTION TRIM(WS-EDIT) "x" DELIMITED BY SIZE
             INTO WS-OBSERVED
         MOVE EN-ITEM-COUNT(WS-ROW) TO WS-EDIT
         STRING FUNCTION TRIM(WS-OBSERVED) FUNCTION TRIM(WS-EDIT) " left" DELIMITED BY SIZE
             INTO WS-OBSERVED
         COMPUTE WS-EDIT = IP-LIFETIME - EN-AGE(WS-ROW)
         STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE
             INTO WS-OBSERVED
     ELSE
         STRING FUNCTION TRIM(WS-OBSERVED) " yaw" DELIMITED BY SIZE INTO WS-OBSERVED
         COMPUTE WS-FEDIT ROUNDED = EN-YAW(WS-ROW) PERFORM ADD-FEDIT
         MOVE EN-HEALTH(WS-ROW) TO WS-EDIT
         STRING FUNCTION TRIM(WS-OBSERVED) " health " FUNCTION TRIM(WS-EDIT) " vy"
             DELIMITED BY SIZE INTO WS-OBSERVED
         COMPUTE WS-FEDIT ROUNDED = EN-VY(WS-ROW) PERFORM ADD-FEDIT
     END-IF.

 ADD-FEDIT.
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-FEDIT) DELIMITED BY SIZE
         INTO WS-OBSERVED.

 ADD-GET.
     CALL "TEST-NBT-GET" USING PB-BUFFER WS-ROOT WS-PATH WS-TEXT
     STRING FUNCTION TRIM(WS-OBSERVED) " " FUNCTION TRIM(WS-TEXT) DELIMITED BY SIZE
         INTO WS-OBSERVED.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-OBSERVED) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-ENTITY-NBT.

 COPY CORETEST.
