*> The worldgen entity channel (GENENT.cpy; docs/design/world-types.md "Entities of generated structures"): a structure placed by a generation job asks for the entities of its templates and markers
*> (villagers, golems, cats, animals, piglins, the mobs of the mansion markers, the witch of a swamp hut, the guardians of a monument) because a worker cannot spawn one. The requests travel with
*> the job like the block-entity requests (GBE-KEEP) and are made by WORLD-CHUNK-LOAD on the main thread, once, in the chunk that was generated (a chunk read from its file asks for none).
*>
*> Entry points:
*>   GENT-ADD USING x, y, z (FLOAT-LONG), yaw (FLOAT-SHORT), length (BINARY-LONG), compound (PIC X(1344): the entity compound's payload with its End tag): appends a request to GEN-ENT-LEVEL (at
*>     most GE-MAX; GEL-LOST counts the rest; a compound longer than GE-NBT-MAX is counted as lost)
*>   GENT-ADD-MOB USING x, y, z (FLOAT-LONG), id (PIC X(32), "minecraft:witch" or the bare key), persistent (BINARY-LONG): a request for a mob made by code (a marker): the compound is the id and
*>     PersistenceRequired
*>   GENT-ADD-FRAME USING x, y, z (BINARY-LONG, the cell of the marker), direction (data value 2 north to 5 east: the way the frame faces), item key (PIC X(32), "minecraft:elytra"): a request for an
*>     item frame holding one of the item (36-8 9.4 Elytra); the compound is {id: "minecraft:item_frame", Facing, Item: {id, count 1}} and the position the cell's centre moved 0.46875 against the facing
*>     (the hanging entity's own rule, decor-44b.cob ITEM-FRAME-PLACE)
*>   GENT-ADD-BOX USING kind, min x, y, z, max x, y, z (BINARY-LONG): a box of a structure that overrides the natural spawn lists (STRUCTOVR.cpy) that intersects the chunk being generated; at most
*>     GE-BOX-MAX per chunk (GEL-BOX-LOST counts the rest)
*>   GENT-KEEP USING job: appends the level's requests to the job's list (GJ-ENT, bounded) and empties the level's list
*>   GENT-APPLY USING dimension row, chunk row: each request of GEN-ENT (GE-DATA) is made by ENTITY-NBT-ONE (the loader of the entities/ files: the id, the keys the core models, the position
*>     and the rotation the request names) unless the entity table is nearly full or an entity of the dimension already stands within a quarter block of the position (the chunk was generated
*>     again while the entities of its first generation were kept); the list is emptied. The boxes of GE-BOX are registered with the chunk (SO-REGISTER, struct-override.cob) first.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GENT-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENENT.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 01 L-LEN                  BINARY-LONG.
 01 L-NBT                  PIC X(1344).
 PROCEDURE DIVISION USING L-X L-Y L-Z L-YAW L-LEN L-NBT.
     IF GEL-COUNT >= GE-MAX OR L-LEN > GE-NBT-MAX OR L-LEN < 1
         ADD 1 TO GEL-LOST
         GOBACK
     END-IF
     ADD 1 TO GEL-COUNT
     MOVE L-X TO GEL-X(GEL-COUNT)
     MOVE L-Y TO GEL-Y(GEL-COUNT)
     MOVE L-Z TO GEL-Z(GEL-COUNT)
     MOVE L-YAW TO GEL-YAW(GEL-COUNT)
     MOVE L-LEN TO GEL-LEN(GEL-COUNT)
     MOVE L-NBT(1:L-LEN) TO GEL-NBT(GEL-COUNT)(1:L-LEN)
     GOBACK.
 END PROGRAM GENT-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GENT-ADD-MOB.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NBT                 PIC X(1344).
 01 WS-POINTER             BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-ID                  PIC X(48).
 01 WS-ID-LENGTH           BINARY-LONG.
 01 WS-CODE                PIC X.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-FLAG                PIC X.
 LINKAGE SECTION.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-ID                   PIC X(32).
 01 L-PERSISTENT           BINARY-LONG.
 PROCEDURE DIVISION USING L-X L-Y L-Z L-ID L-PERSISTENT.
     MOVE SPACES TO WS-ID
     IF L-ID(1:10) = "minecraft:"
         MOVE FUNCTION TRIM(L-ID) TO WS-ID
     ELSE
         STRING "minecraft:" FUNCTION TRIM(L-ID) DELIMITED BY SIZE INTO WS-ID
     END-IF
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ID)) TO WS-ID-LENGTH
     MOVE FUNCTION CHAR(WS-ID-LENGTH + 1) TO WS-CODE
     MOVE FUNCTION CHAR(L-PERSISTENT + 1) TO WS-FLAG
     MOVE SPACES TO WS-NBT
     MOVE 1 TO WS-POINTER
*>   {id: "<id>", PersistenceRequired: <0|1>b} as the payload of a compound: String "id", Byte "PersistenceRequired" (19 characters), End
     STRING X"080002" "id" X"00" WS-CODE WS-ID(1:WS-ID-LENGTH) X"010013" "PersistenceRequired" WS-FLAG X"00"
         DELIMITED BY SIZE INTO WS-NBT WITH POINTER WS-POINTER
     COMPUTE WS-LEN = WS-POINTER - 1
     CALL "GENT-ADD" USING L-X L-Y L-Z WS-YAW WS-LEN WS-NBT
     GOBACK.
 END PROGRAM GENT-ADD-MOB.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GENT-ADD-FRAME.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-NBT                 PIC X(1344).
 01 WS-POINTER             BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-CODE                PIC X.
 01 WS-FACING              PIC X.
 01 WS-DX                  BINARY-LONG.
 01 WS-DY                  BINARY-LONG.
 01 WS-DZ                  BINARY-LONG.
 01 WS-X                   FLOAT-LONG.
 01 WS-Y                   FLOAT-LONG.
 01 WS-Z                   FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-X                    BINARY-LONG.
 01 L-Y                    BINARY-LONG.
 01 L-Z                    BINARY-LONG.
 01 L-DIRECTION            BINARY-LONG.
 01 L-ITEM                 PIC X(32).
 PROCEDURE DIVISION USING L-X L-Y L-Z L-DIRECTION L-ITEM.
     MOVE FUNCTION LENGTH(FUNCTION TRIM(L-ITEM)) TO WS-KEY-LENGTH
     MOVE FUNCTION CHAR(WS-KEY-LENGTH + 1) TO WS-CODE
     MOVE FUNCTION CHAR(L-DIRECTION + 1) TO WS-FACING
     MOVE SPACES TO WS-NBT
     MOVE 1 TO WS-POINTER
*>   {id: "minecraft:item_frame", Facing: <d>b, Item: {id: "<key>", count: 1}} as the payload of a compound
     STRING X"080002" "id" X"0014" "minecraft:item_frame" X"010006" "Facing" WS-FACING X"0A0004" "Item" X"080002" "id" X"00" WS-CODE
         L-ITEM(1:WS-KEY-LENGTH) X"030005" "count" X"00000001" X"00" X"00"
         DELIMITED BY SIZE INTO WS-NBT WITH POINTER WS-POINTER
     COMPUTE WS-LEN = WS-POINTER - 1
     CALL "DECOR-STEP" USING L-DIRECTION WS-DX WS-DY WS-DZ
     COMPUTE WS-X = L-X + 0.5 - WS-DX * 0.46875
     COMPUTE WS-Y = L-Y + 0.5
     COMPUTE WS-Z = L-Z + 0.5 - WS-DZ * 0.46875
     CALL "GENT-ADD" USING WS-X WS-Y WS-Z WS-YAW WS-LEN WS-NBT
     GOBACK.
 END PROGRAM GENT-ADD-FRAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GENT-ADD-BOX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENENT.
 LINKAGE SECTION.
 01 L-KIND                 BINARY-LONG.
 01 L-X0                   BINARY-LONG.
 01 L-Y0                   BINARY-LONG.
 01 L-Z0                   BINARY-LONG.
 01 L-X1                   BINARY-LONG.
 01 L-Y1                   BINARY-LONG.
 01 L-Z1                   BINARY-LONG.
 PROCEDURE DIVISION USING L-KIND L-X0 L-Y0 L-Z0 L-X1 L-Y1 L-Z1.
     IF GEL-BOX-COUNT >= GE-BOX-MAX
         ADD 1 TO GEL-BOX-LOST
         GOBACK
     END-IF
     ADD 1 TO GEL-BOX-COUNT
     MOVE L-KIND TO GEL-B-KIND(GEL-BOX-COUNT)
     MOVE L-X0 TO GEL-B-MIN-X(GEL-BOX-COUNT)
     MOVE L-Y0 TO GEL-B-MIN-Y(GEL-BOX-COUNT)
     MOVE L-Z0 TO GEL-B-MIN-Z(GEL-BOX-COUNT)
     MOVE L-X1 TO GEL-B-MAX-X(GEL-BOX-COUNT)
     MOVE L-Y1 TO GEL-B-MAX-Y(GEL-BOX-COUNT)
     MOVE L-Z1 TO GEL-B-MAX-Z(GEL-BOX-COUNT)
     GOBACK.
 END PROGRAM GENT-ADD-BOX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GENT-KEEP.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY GENENT.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 01 L-JOB.
    COPY GENJOB REPLACING LEADING ==GJ-== BY ==J-==.
 PROCEDURE DIVISION USING L-JOB.
     ADD GEL-LOST TO J-ENT-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GEL-COUNT
         IF J-ENT-COUNT < GE-MAX
             ADD 1 TO J-ENT-COUNT
             MOVE GEL-ENTRY(WS-I) TO J-ENT-ENTRY(J-ENT-COUNT)
         ELSE
             ADD 1 TO J-ENT-LOST
         END-IF
     END-PERFORM
     ADD GEL-BOX-LOST TO J-ENT-BOX-LOST
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GEL-BOX-COUNT
         IF J-ENT-BOX-COUNT < GE-BOX-MAX
             ADD 1 TO J-ENT-BOX-COUNT
             MOVE GEL-BOX(WS-I) TO J-ENT-BOX(J-ENT-BOX-COUNT)
         ELSE
             ADD 1 TO J-ENT-BOX-LOST
         END-IF
     END-PERFORM
     MOVE 0 TO GEL-COUNT GEL-LOST GEL-BOX-COUNT GEL-BOX-LOST
     GOBACK.
 END PROGRAM GENT-KEEP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GENT-APPLY.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY GENENT.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 2048.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-USED                BINARY-LONG.
 01 WS-FIRST-NEW           BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-DX                  FLOAT-LONG.
 01 WS-DY                  FLOAT-LONG.
 01 WS-DZ                  FLOAT-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-THREE               BINARY-LONG VALUE 3.
 01 WS-TWO                 BINARY-LONG VALUE 2.
 01 WS-T-DOUBLE            BINARY-LONG VALUE 6.
 01 WS-T-FLOAT             BINARY-LONG VALUE 5.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-POS-NAME            PIC X(3) VALUE "Pos".
 01 WS-POS-LENGTH          BINARY-LONG VALUE 3.
 01 WS-ROT-NAME            PIC X(8) VALUE "Rotation".
 01 WS-ROT-LENGTH          BINARY-LONG VALUE 8.
 01 WS-PITCH               FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-ROW                  BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-ROW.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GE-BOX-COUNT
         CALL "SO-REGISTER" USING L-DIM CK-X(L-ROW) CK-Z(L-ROW) GE-B-KIND(WS-I) GE-B-MIN-X(WS-I) GE-B-MIN-Y(WS-I) GE-B-MIN-Z(WS-I)
             GE-B-MAX-X(WS-I) GE-B-MAX-Y(WS-I) GE-B-MAX-Z(WS-I)
     END-PERFORM
     MOVE 0 TO GE-BOX-COUNT GE-BOX-LOST
     IF GE-COUNT = 0
         MOVE 0 TO GE-LOST
         GOBACK
     END-IF
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     MOVE CW-NEXT-ENTITY-ID TO WS-FIRST-NEW
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > GE-COUNT
*>       the entity table must keep room (a full table is fatal), and an entity standing at the position before this list was applied was made by an earlier generation of the chunk (mobs
*>       of one list may share a position: the group of allays of a mansion marker)
         MOVE 0 TO WS-USED WS-SAME
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > EN-COUNT
             IF EN-USED(WS-E) = 1
                 ADD 1 TO WS-USED
                 IF EN-PLAYER(WS-E) = 0 AND EN-DIM(WS-E) = L-DIM AND EN-ID(WS-E) < WS-FIRST-NEW
                     COMPUTE WS-DX = EN-X(WS-E) - GE-X(WS-I)
                     COMPUTE WS-DY = EN-Y(WS-E) - GE-Y(WS-I)
                     COMPUTE WS-DZ = EN-Z(WS-E) - GE-Z(WS-I)
                     IF FUNCTION ABS(WS-DX) < 0.25 AND FUNCTION ABS(WS-DY) < 1 AND FUNCTION ABS(WS-DZ) < 0.25
                         MOVE 1 TO WS-SAME
                     END-IF
                 END-IF
             END-IF
         END-PERFORM
         IF WS-SAME = 0 AND WS-USED < CORE-MAX-ENTITIES - 16
             CALL "PB-RESET" USING PB-BUFFER
*>           the compound without its End tag, then Pos and Rotation of the request (a later key of the same name wins in the reader), then the End tag
             COMPUTE WS-LEN = GE-LEN(WS-I) - 1
             CALL "PB-APPEND-BYTES" USING PB-BUFFER GE-NBT(WS-I) WS-LEN
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-POS-NAME WS-POS-LENGTH WS-T-DOUBLE WS-THREE
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-POS-NAME WS-ELEMENT GE-X(WS-I)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-POS-NAME WS-ELEMENT GE-Y(WS-I)
             CALL "NBT-WRITE-DOUBLE" USING PB-BUFFER WS-POS-NAME WS-ELEMENT GE-Z(WS-I)
             CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-ROT-NAME WS-ROT-LENGTH WS-T-FLOAT WS-TWO
             CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-ROT-NAME WS-ELEMENT GE-YAW(WS-I)
             CALL "NBT-WRITE-FLOAT" USING PB-BUFFER WS-ROT-NAME WS-ELEMENT WS-PITCH
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
             MOVE 0 TO PB-POS
             CALL "ENTITY-NBT-ONE" USING L-DIM PB-BUFFER
         END-IF
     END-PERFORM
     MOVE 0 TO GE-COUNT GE-LOST
     GOBACK.
 END PROGRAM GENT-APPLY.
