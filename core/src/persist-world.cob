*> The world folder (docs/protocol/07-nbt-and-anvil.md §9; contracts/world-folder.md; FR-004, FR-014):
*> level.dat, access.dat, players/<offline-uuid>.dat (gzip NBT files through proto NBT-FILE-WRITE and
*> NBT-FILE-READ, 07 §5.1) and, per dimension, dimensions/<namespace>/<path>/region and entities
*> (Anvil region files, core/src/region.cob). Every root carries DataVersion 5023 (07 §9.1).
*>
*> Programs that build NBT name each tag through WN (the name) and WL (its byte length); list
*> elements use the name length -1 (contracts/proto-api.md §5). Programs that read walk compounds
*> entry by entry (NBT-READ-COMPOUND-NEXT), act on the keys they know and skip the others
*> (NBT-READ-SKIP), so key order never matters (07 §1.2). A malformed stream leaves PB-ERROR set.

*> The dimension folders, the whole-world save and load and the key helpers (split from the old persistence.cob).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-DIM-DIR.
*> USING dimension row (BINARY-LONG), kind (PIC X(8): "region" or "entities"), folder out
*> (PIC X(1024), space filled), folder length out: <world>/dimensions/<namespace>/<path>/<kind>,
*> the dimension key split at its colon (07 §9.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-KEY                 PIC X(32).
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIM                  BINARY-LONG.
 01 L-KIND                 PIC X(8).
 01 L-DIR                  PIC X(1024).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIM L-KIND L-DIR L-LENGTH.
     MOVE DM-KEY(L-DIM) TO WS-KEY
     INSPECT WS-KEY REPLACING FIRST ":" BY "/"
     MOVE SPACES TO L-DIR
     MOVE 1 TO WS-PTR
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/dimensions/" WS-KEY(1:DM-KEY-LENGTH(L-DIM)) "/"
         DELIMITED BY SIZE L-KIND DELIMITED BY SPACE INTO L-DIR WITH POINTER WS-PTR
     COMPUTE L-LENGTH = WS-PTR - 1
     GOBACK.
 END PROGRAM PERSIST-DIM-DIR.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-DIRS.
*> No parameters: creates the folders of the world (07 §9.1) that do not exist yet: the world
*> folder, players/, and for every enabled dimension dimensions/<namespace>/<path>/ with region/ and
*> entities/. A folder that cannot be created shows up as a failed write later.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY DIMENSIONS.
 01 WS-NAME                PIC X(1100).
 01 WS-KEY                 PIC X(32).
 01 WS-NAMESPACE           PIC X(32).
 01 WS-D                   BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-DIR                 PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-REGION              PIC X(8) VALUE "region".
 01 WS-ENTITIES            PIC X(8) VALUE "entities".
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-NAME
     MOVE CW-FOLDER(1:CW-FOLDER-LENGTH) TO WS-NAME
     CALL "CBL_CREATE_DIR" USING WS-NAME
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/players" DELIMITED BY SIZE INTO WS-NAME
     CALL "CBL_CREATE_DIR" USING WS-NAME
     IF CW-LAYOUT = 1
         MOVE SPACES TO WS-NAME
         STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/players/data" DELIMITED BY SIZE INTO WS-NAME
         CALL "CBL_CREATE_DIR" USING WS-NAME
     END-IF
     MOVE SPACES TO WS-NAME
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/dimensions" DELIMITED BY SIZE INTO WS-NAME
     CALL "CBL_CREATE_DIR" USING WS-NAME
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         MOVE CW-DIM(WS-D) TO WS-DIM
         MOVE DM-KEY(WS-DIM) TO WS-KEY
         MOVE SPACES TO WS-NAMESPACE
         UNSTRING WS-KEY DELIMITED BY ":" INTO WS-NAMESPACE
         MOVE SPACES TO WS-NAME
         STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/dimensions/" DELIMITED BY SIZE
             WS-NAMESPACE DELIMITED BY SPACE INTO WS-NAME
         CALL "CBL_CREATE_DIR" USING WS-NAME
         CALL "PERSIST-DIM-DIR" USING WS-DIM WS-REGION WS-DIR WS-LENGTH
         MOVE SPACES TO WS-NAME
         MOVE WS-DIR(1:WS-LENGTH - 7) TO WS-NAME
         CALL "CBL_CREATE_DIR" USING WS-NAME
         MOVE WS-DIR TO WS-NAME
         CALL "CBL_CREATE_DIR" USING WS-NAME
         CALL "PERSIST-DIM-DIR" USING WS-DIM WS-ENTITIES WS-DIR WS-LENGTH
         MOVE WS-DIR TO WS-NAME
         CALL "CBL_CREATE_DIR" USING WS-NAME
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM PERSIST-DIRS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-SAVE.
*> No parameters: writes the whole world (FR-014; 07 §9.5): every changed chunk, the entities of
*> every enabled dimension (PERSIST-ENTITIES-SAVE), the file of every player in play and of every
*> player who left since the previous save (KN-DIRTY), level.dat and access.dat.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-ROW                 BINARY-LONG.
 01 WS-D                   BINARY-LONG.
 01 WS-FIGHT-SAVE          BINARY-LONG VALUE 2.
 01 WS-RAID-SAVE           BINARY-LONG VALUE 2.
 01 WS-FIGHT-RECORD        PIC X(1024).
 PROCEDURE DIVISION.
     CALL "PERSIST-DIRS"
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CK-COUNT
         IF CK-USED(WS-ROW) = 1 AND CK-CHANGED(WS-ROW) = 1
             CALL "PERSIST-CHUNK-SAVE" USING WS-ROW
         END-IF
     END-PERFORM
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         CALL "PERSIST-ENTITIES-SAVE" USING CW-DIM(WS-D)
     END-PERFORM
     CALL "RAID-IO" USING WS-RAID-SAVE
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > CORE-MAX-PLAYERS
         IF PL-USED(WS-ROW) = 1
             IF CN-PHASE(PL-CONN(WS-ROW)) = PH-PLAY
                 CALL "PLAYER-REMEMBER" USING WS-ROW
             END-IF
         END-IF
     END-PERFORM
     PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > KN-COUNT
         IF KN-DIRTY(WS-ROW) = 1
             CALL "PLAYER-DAT-WRITE" USING WS-ROW
             MOVE 0 TO KN-DIRTY(WS-ROW)
         END-IF
     END-PERFORM
     CALL "END-FIGHT-IO" USING WS-FIGHT-SAVE WS-FIGHT-RECORD
     CALL "FLAT-SETTINGS-SAVE"
     CALL "LEVEL-DAT-WRITE"
     CALL "ACCESS-DAT-WRITE"
     GOBACK.
 END PROGRAM WORLD-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-LOAD.
*> No parameters: reads an existing world folder (CORE-WORLD-OPEN, created flag 0): level.dat,
*> access.dat and the entities of every enabled dimension. Chunks are read from the region files
*> when first used (WORLD-CHUNK-LOAD), player files when the player joins (PLAYER-CREATE).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 01 WS-D                   BINARY-LONG.
 01 WS-FILE                PIC X(1100).
 01 WS-INFO                PIC X(16).
 01 WS-FIGHT-LOAD          BINARY-LONG VALUE 1.
 01 WS-RAID-LOAD           BINARY-LONG VALUE 1.
 01 WS-FIGHT-RECORD        PIC X(1024).
 PROCEDURE DIVISION.
     CALL "LEVEL-DAT-READ"
*>   A world of a real 26.3 game has no access.dat (its lists are other files): the lists stay empty.
     MOVE SPACES TO WS-FILE
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) "/access.dat" X"00" DELIMITED BY SIZE INTO WS-FILE
     CALL "CBL_CHECK_FILE_EXIST" USING WS-FILE WS-INFO
     IF RETURN-CODE = 0
         CALL "ACCESS-DAT-READ"
     END-IF
     MOVE 0 TO RETURN-CODE
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         CALL "PERSIST-ENTITIES-LOAD" USING CW-DIM(WS-D)
     END-PERFORM
     CALL "RAID-IO" USING WS-RAID-LOAD
     CALL "END-FIGHT-IO" USING WS-FIGHT-LOAD WS-FIGHT-RECORD
     GOBACK.
 END PROGRAM WORLD-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-NAMESPACED.
*> USING key (PIC X(48)), key length (BINARY-LONG), out key (PIC X(64)), out length (BINARY-LONG): the key as the world
*> folder stores it. A standard set stores some keys without a namespace (CBLOCKS.cpy), the folder always holds
*> "minecraft:" + path for them (07 section 7.3); a key that has a namespace, and every key of the cobolcraft
*> set, is written as it is.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 01 WS-COLONS              BINARY-LONG.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(48).
 01 L-LENGTH               BINARY-LONG.
 01 L-OUT                  PIC X(64).
 01 L-OUT-LENGTH           BINARY-LONG.
 PROCEDURE DIVISION USING L-KEY L-LENGTH L-OUT L-OUT-LENGTH.
     MOVE SPACES TO L-OUT
     MOVE 0 TO WS-COLONS
     INSPECT L-KEY(1:L-LENGTH) TALLYING WS-COLONS FOR ALL ":"
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND WS-COLONS = 0
         STRING "minecraft:" L-KEY(1:L-LENGTH) DELIMITED BY SIZE INTO L-OUT
         COMPUTE L-OUT-LENGTH = L-LENGTH + 10
     ELSE
         MOVE L-KEY(1:L-LENGTH) TO L-OUT
         MOVE L-LENGTH TO L-OUT-LENGTH
     END-IF
     GOBACK.
 END PROGRAM PERSIST-NAMESPACED.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-LOCAL-KEY.
*> USING key as the folder stores it (PIC X(64), space filled), key out (PIC X(48)): the key as the open set names it,
*> the inverse of PERSIST-NAMESPACED. A standard set holds some keys without "minecraft:" (CITEMS.cpy, CBLOCKS.cpy), so
*> the prefix is cut for it; the cobolcraft set keeps every key as it is.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CONTENT.
 LINKAGE SECTION.
 01 L-KEY                  PIC X(64).
 01 L-OUT                  PIC X(48).
 PROCEDURE DIVISION USING L-KEY L-OUT.
     MOVE SPACES TO L-OUT
     IF CT-SET-TYPE NOT = CT-TYPE-COBOLCRAFT AND L-KEY(1:10) = "minecraft:"
         MOVE L-KEY(11:54) TO L-OUT
     ELSE
         MOVE L-KEY TO L-OUT
     END-IF
     GOBACK.
 END PROGRAM PERSIST-LOCAL-KEY.
