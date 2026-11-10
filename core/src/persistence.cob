*> The world folder (docs/protocol/07-nbt-and-anvil.md §9; contracts/world-folder.md; FR-004, FR-014):
*> level.dat, access.dat, players/<offline-uuid>.dat (gzip NBT files through proto NBT-FILE-WRITE and
*> NBT-FILE-READ, 07 §5.1) and, per dimension, dimensions/<namespace>/<path>/region and entities
*> (Anvil region files, core/src/region.cob). Every root carries DataVersion 5023 (07 §9.1).
*>
*> Programs that build NBT name each tag through WN (the name) and WL (its byte length); list
*> elements use the name length -1 (contracts/proto-api.md §5). Programs that read walk compounds
*> entry by entry (NBT-READ-COMPOUND-NEXT), act on the keys they know and skip the others
*> (NBT-READ-SKIP), so key order never matters (07 §1.2). A malformed stream leaves PB-ERROR set.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-PATH.
*> USING suffix (PIC X(128): the path inside the world folder, starting with "/", space filled),
*> path out (PIC X(1100), space filled), path length out (BINARY-LONG).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 LINKAGE SECTION.
 01 L-SUFFIX               PIC X(128).
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-SUFFIX L-PATH L-LENGTH.
     MOVE SPACES TO L-PATH
     STRING CW-FOLDER(1:CW-FOLDER-LENGTH) FUNCTION TRIM(L-SUFFIX) DELIMITED BY SIZE INTO L-PATH
     COMPUTE L-LENGTH = CW-FOLDER-LENGTH + FUNCTION LENGTH(FUNCTION TRIM(L-SUFFIX))
     GOBACK.
 END PROGRAM PERSIST-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-READ-FILE.
*> USING path (PIC X(1100)), path length, PB-BUFFER (initialised): reads the gzip NBT file
*> (NBT-FILE-READ) and its file root header; PB-POS is left at the root compound payload. A file
*> that is missing or cannot be read as gzip NBT is fatal (research R14): "world: cannot read
*> <path>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FRAMING             BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-FATAL               PIC X(1200).
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-LENGTH PB-BUFFER.
     CALL "NBT-FILE-READ" USING L-PATH L-LENGTH PB-BUFFER WS-OUTCOME
     IF WS-OUTCOME NOT = 0
         MOVE LOW-VALUES TO WS-FATAL
         STRING "world: cannot read " L-PATH(1:L-LENGTH) DELIMITED BY SIZE INTO WS-FATAL
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FRAMING WS-TYPE
     GOBACK.
 END PROGRAM PERSIST-READ-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-WRITE-FILE.
*> USING path (PIC X(1100)), path length, PB-BUFFER (a named-root NBT stream): writes the gzip NBT
*> file (NBT-FILE-WRITE); the outcome goes to PERSIST-WRITE-CHECK.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-OUTCOME             BINARY-LONG.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-LENGTH PB-BUFFER.
     CALL "NBT-FILE-WRITE" USING L-PATH L-LENGTH PB-BUFFER WS-OUTCOME
     CALL "PERSIST-WRITE-CHECK" USING WS-OUTCOME L-PATH L-LENGTH
     GOBACK.
 END PROGRAM PERSIST-WRITE-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-WRITE-CHECK.
*> USING outcome (BINARY-LONG, 0 written), path (PIC X(1100): the file, or the region folder),
*> path length: the check after every write of the world folder. A failed write is fatal
*> (research R14): "world save: cannot write <path>".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-FATAL               PIC X(1200).
 LINKAGE SECTION.
 01 L-OUTCOME              BINARY-LONG.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-OUTCOME L-PATH L-LENGTH.
     IF L-OUTCOME NOT = 0
         MOVE LOW-VALUES TO WS-FATAL
         STRING "world save: cannot write " L-PATH(1:L-LENGTH) DELIMITED BY SIZE INTO WS-FATAL
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-FATAL
     END-IF
     GOBACK.
 END PROGRAM PERSIST-WRITE-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-UUID-TEXT.
*> USING offline UUID (PIC X(16)), text out (PIC X(36)): hyphenated lower-case hex (07 §9.1).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-HEX                 PIC X(16) VALUE "0123456789abcdef".
 01 WS-I                   BINARY-LONG.
 01 WS-BYTE                BINARY-LONG.
 01 WS-HIGH                BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 LINKAGE SECTION.
 01 L-UUID                 PIC X(16).
 01 L-TEXT                 PIC X(36).
 PROCEDURE DIVISION USING L-UUID L-TEXT.
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 16
         COMPUTE WS-BYTE = FUNCTION ORD(L-UUID(WS-I:1)) - 1
         COMPUTE WS-HIGH = WS-BYTE / 16
         MOVE WS-HEX(WS-HIGH + 1:1) TO L-TEXT(WS-PTR:1)
         MOVE WS-HEX(WS-BYTE - WS-HIGH * 16 + 1:1) TO L-TEXT(WS-PTR + 1:1)
         ADD 2 TO WS-PTR
         IF WS-I = 4 OR WS-I = 6 OR WS-I = 8 OR WS-I = 10
             MOVE "-" TO L-TEXT(WS-PTR:1)
             ADD 1 TO WS-PTR
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-UUID-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. PERSIST-UUID-INTS.
*> USING direction (BINARY-LONG: 0 UUID to Ints, 1 Ints to UUID), offline UUID (PIC X(16)), Ints
*> (table of 4 BINARY-LONG): the UUID as four signed big-endian Ints, most significant first
*> (07 §9.2, Open question 8).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 01 WS-VALUE               BINARY-DOUBLE.
 01 WS-FOUR                PIC X(4).
 LINKAGE SECTION.
 01 L-DIRECTION            BINARY-LONG.
 01 L-UUID                 PIC X(16).
 01 L-INTS.
    05 L-INT               BINARY-LONG OCCURS 4 TIMES.
 PROCEDURE DIVISION USING L-DIRECTION L-UUID L-INTS.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         IF L-DIRECTION = 0
             MOVE L-UUID(WS-I * 4 - 3:4) TO WS-FOUR
             CALL "REGION-BE-GET" USING WS-FOUR WS-VALUE
             IF WS-VALUE >= 2147483648
                 SUBTRACT 4294967296 FROM WS-VALUE
             END-IF
             MOVE WS-VALUE TO L-INT(WS-I)
         ELSE
             MOVE L-INT(WS-I) TO WS-VALUE
             IF WS-VALUE < 0
                 ADD 4294967296 TO WS-VALUE
             END-IF
             CALL "REGION-BE-PUT" USING WS-VALUE WS-FOUR
             MOVE WS-FOUR TO L-UUID(WS-I * 4 - 3:4)
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM PERSIST-UUID-INTS.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACCESS-DAT-WRITE.
*> No parameters: writes <world>/access.dat (07 §9.2): DataVersion; Operators, Bans and AllowList,
*> each a list of {Name, UUID: Int Array of 4}; AllowListEnforced.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-DATA-VERSION        BINARY-LONG VALUE 5023.
 01 WS-T-COMPOUND          BINARY-LONG VALUE 10.
 01 WS-TO-INTS             BINARY-LONG VALUE 0.
 01 WS-FOUR                BINARY-LONG VALUE 4.
 01 WS-INT                 BINARY-LONG.
 01 WS-INTS.
    05 WS-INT-ITEM         BINARY-LONG OCCURS 4 TIMES.
 01 WS-LIST-NAMES.
    05 FILLER              PIC X(16) VALUE "Operators".
    05 FILLER              BINARY-LONG VALUE 9.
    05 FILLER              PIC X(16) VALUE "Bans".
    05 FILLER              BINARY-LONG VALUE 4.
    05 FILLER              PIC X(16) VALUE "AllowList".
    05 FILLER              BINARY-LONG VALUE 9.
 01 WS-LIST-TABLE REDEFINES WS-LIST-NAMES.
    05 WS-LIST-ENTRY OCCURS 3 TIMES.
       10 WS-LIST-NAME     PIC X(16).
       10 WS-LIST-LENGTH   BINARY-LONG.
 01 WS-L                   BINARY-LONG.
 01 WS-ROW                 BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/access.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "DataVersion" TO WN MOVE 11 TO WL
     CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL WS-DATA-VERSION
     PERFORM VARYING WS-L FROM 1 BY 1 UNTIL WS-L > 3
         CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WS-LIST-NAME(WS-L) WS-LIST-LENGTH(WS-L)
             WS-T-COMPOUND AC-COUNT(WS-L)
         PERFORM VARYING WS-ROW FROM 1 BY 1 UNTIL WS-ROW > AC-COUNT(WS-L)
             CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
             MOVE "Name" TO WN MOVE 4 TO WL
             CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL AC-NAME(WS-L, WS-ROW)
                 AC-NAME-LENGTH(WS-L, WS-ROW)
             MOVE "UUID" TO WN
             CALL "PERSIST-UUID-INTS" USING WS-TO-INTS AC-UUID(WS-L, WS-ROW) WS-INTS
             CALL "NBT-WRITE-INT-ARRAY" USING PB-BUFFER WN WL WS-FOUR WS-INTS
             CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
         END-PERFORM
         CALL "NBT-WRITE-LIST-END" USING PB-BUFFER
     END-PERFORM
     MOVE "AllowListEnforced" TO WN MOVE 17 TO WL
     MOVE AC-ENFORCED TO WS-INT
     CALL "NBT-WRITE-BYTE" USING PB-BUFFER WN WL WS-INT
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-WRITE-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     GOBACK.
 END PROGRAM ACCESS-DAT-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ACCESS-DAT-READ.
*> No parameters: reads <world>/access.dat into the access lists (every list emptied first; entries
*> past CORE-MAX-ACCESS are dropped by ACCESS-ADD) and the enforcement flag.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CORESTATE.
 COPY PROTO.
 01 WS-READY               PIC 9 VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WN                     PIC X(32).
 01 WL                     BINARY-LONG.
 01 WS-NAME-CAPACITY       BINARY-LONG VALUE 32.
 01 WS-TYPE                BINARY-LONG.
 01 WS-INNER-TYPE          BINARY-LONG.
 01 WS-ELEMENT-TYPE        BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-LIST                BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 01 WS-INT-CAPACITY        BINARY-LONG VALUE 4.
 01 WS-INT-COUNT           BINARY-LONG.
 01 WS-INTS.
    05 WS-INT-ITEM         BINARY-LONG OCCURS 4 TIMES.
 01 WS-TO-UUID             BINARY-LONG VALUE 1.
 01 WS-NAME                PIC X(16).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-NAME-SIZE           BINARY-LONG VALUE 16.
 01 WS-UUID                PIC X(16).
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-SUFFIX              PIC X(128) VALUE "/access.dat".
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 PROCEDURE DIVISION.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     INITIALIZE CORE-ACCESS
     CALL "PERSIST-PATH" USING WS-SUFFIX WS-PATH WS-PATH-LENGTH
     CALL "PERSIST-READ-FILE" USING WS-PATH WS-PATH-LENGTH PB-BUFFER
     PERFORM UNTIL PB-ERROR = 1
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WS-NAME-CAPACITY WL
         IF WS-TYPE = 0
             EXIT PERFORM
         END-IF
         EVALUATE TRUE
             WHEN WN = "Operators"
                 MOVE ACCESS-OPERATORS TO WS-LIST
             WHEN WN = "Bans"
                 MOVE ACCESS-BANS TO WS-LIST
             WHEN WN = "AllowList"
                 MOVE ACCESS-ALLOW TO WS-LIST
             WHEN OTHER
                 MOVE 0 TO WS-LIST
         END-EVALUATE
         EVALUATE TRUE
             WHEN WS-LIST > 0 AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ELEMENT-TYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT OR PB-ERROR = 1
                     MOVE SPACES TO WS-NAME
                     MOVE LOW-VALUES TO WS-UUID
                     MOVE 0 TO WS-NAME-LENGTH
                     PERFORM UNTIL PB-ERROR = 1
                         MOVE SPACES TO WN
                         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-INNER-TYPE WN
                             WS-NAME-CAPACITY WL
                         IF WS-INNER-TYPE = 0
                             EXIT PERFORM
                         END-IF
                         EVALUATE TRUE
                             WHEN WN = "Name" AND WS-INNER-TYPE = 8
                                 CALL "NBT-READ-STRING" USING PB-BUFFER WS-NAME WS-NAME-SIZE
                                     WS-NAME-LENGTH
                             WHEN WN = "UUID" AND WS-INNER-TYPE = 11
                                 CALL "NBT-READ-INT-ARRAY" USING PB-BUFFER WS-INT-CAPACITY
                                     WS-INT-COUNT WS-INTS
                                 CALL "PERSIST-UUID-INTS" USING WS-TO-UUID WS-UUID WS-INTS
                             WHEN OTHER
                                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-INNER-TYPE
                         END-EVALUATE
                     END-PERFORM
                     CALL "ACCESS-ADD" USING WS-LIST WS-NAME WS-NAME-LENGTH WS-UUID WS-OUTCOME
                 END-PERFORM
             WHEN WN = "AllowListEnforced" AND WS-TYPE = 1
                 CALL "PB-GET-BYTE" USING PB-BUFFER WS-INT
                 MOVE WS-INT TO AC-ENFORCED
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     GOBACK.
 END PROGRAM ACCESS-DAT-READ.

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
 PROCEDURE DIVISION.
     CALL "LEVEL-DAT-READ"
     CALL "ACCESS-DAT-READ"
     PERFORM VARYING WS-D FROM 1 BY 1 UNTIL WS-D > CW-DIM-COUNT
         CALL "PERSIST-ENTITIES-LOAD" USING CW-DIM(WS-D)
     END-PERFORM
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
