*> Local packs (US18-1; 08 §1.1, §1.2, §2.3; client-surface §2): LOCAL-PACKS-SCAN lists the packs of
*> <game directory>/resourcepacks/ in byte order: a directory holding pack.mcmeta is a folder pack, a
*> file named *.zip a zip pack, anything else is no pack. Each gets id file/<name>, its description
*> and compatibility (mcmeta.cob) or the problem that makes it unusable, and its pack.png as an
*> icon cell of the UI atlas (scaled to 16 x 16; a pack.png that cannot be decoded shows the
*> missing texture instead). LOCAL-PACK-FIND looks an id up.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOCAL-PACKS-SCAN.
*> USING CLIENT-STATE: fills LP-ENTRY (at most CL-MAX-LOCAL-PACKS) and the icon cells.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-DIRZ                PIC X(1100).
 01 WS-LIST                PIC X(65536).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NAME                PIC X(64).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-ROOT                PIC X(1100).
 01 WS-ROOT-LENGTH         BINARY-LONG.
 01 WS-INFO                PIC X(16).
 01 WS-CHECK               PIC X(1100).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO LP-COUNT LP-ICON-COUNT
     MOVE LOW-VALUES TO WS-DIRZ
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/resourcepacks" DELIMITED BY SIZE INTO WS-DIRZ
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-LIST-COUNT
         MOVE SPACES TO WS-ENTRY
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY COUNT IN WS-LENGTH WITH POINTER WS-PTR
         MOVE SPACES TO WS-NAME
         MOVE WS-ENTRY(2:64) TO WS-NAME
         COMPUTE WS-NAME-LENGTH = FUNCTION MIN(WS-LENGTH - 1, 64)
         MOVE SPACES TO WS-ROOT
         STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/resourcepacks/" WS-NAME(1:WS-NAME-LENGTH)
             DELIMITED BY SIZE INTO WS-ROOT
         COMPUTE WS-ROOT-LENGTH = CL-GAME-DIR-LENGTH + 15 + WS-NAME-LENGTH
         MOVE 0 TO WS-KIND
         IF WS-ENTRY(1:1) = "D"
             MOVE SPACES TO WS-CHECK
             STRING WS-ROOT(1:WS-ROOT-LENGTH) "/pack.mcmeta" DELIMITED BY SIZE INTO WS-CHECK
             CALL "CBL_CHECK_FILE_EXIST" USING WS-CHECK WS-INFO
             IF RETURN-CODE = 0
                 MOVE 1 TO WS-KIND
             END-IF
             MOVE 0 TO RETURN-CODE
         ELSE
             IF WS-NAME-LENGTH > 4
                 IF WS-NAME(WS-NAME-LENGTH - 3:4) = ".zip"
                     MOVE 2 TO WS-KIND
                 END-IF
             END-IF
         END-IF
         IF WS-KIND > 0 AND LP-COUNT < CL-MAX-LOCAL-PACKS
             ADD 1 TO LP-COUNT
             INITIALIZE LP-ENTRY(LP-COUNT)
             MOVE WS-NAME TO LP-NAME(LP-COUNT)
             MOVE WS-NAME-LENGTH TO LP-NAME-LENGTH(LP-COUNT)
             STRING "file/" WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO LP-ID(LP-COUNT)
             COMPUTE LP-ID-LENGTH(LP-COUNT) = WS-NAME-LENGTH + 5
             MOVE WS-KIND TO LP-KIND(LP-COUNT)
             CALL "LOCAL-PACK-READ" USING CLIENT-STATE LP-COUNT WS-ROOT WS-ROOT-LENGTH
         END-IF
     END-PERFORM
*>   The built-in optional skin pack (faithful-pack-mapping 9.7), always listed, last.
     IF LP-COUNT < CL-MAX-LOCAL-PACKS
         ADD 1 TO LP-COUNT
         INITIALIZE LP-ENTRY(LP-COUNT)
         MOVE "Faithful Skin" TO LP-NAME(LP-COUNT)
         MOVE 13 TO LP-NAME-LENGTH(LP-COUNT)
         MOVE "cobolcraft_faithful_skin" TO LP-ID(LP-COUNT)
         MOVE 24 TO LP-ID-LENGTH(LP-COUNT)
         MOVE 3 TO LP-KIND(LP-COUNT)
         MOVE 1 TO LP-VALID(LP-COUNT)
         MOVE 0 TO LP-COMPAT(LP-COUNT) LP-ICON(LP-COUNT)
         MOVE "Uses Faithful 32x textures for CobolCraft blocks and items. Needs the generated vanilla "
             & "pack or a Faithful pack." TO LP-DESC(LP-COUNT)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(LP-DESC(LP-COUNT))) TO LP-DESC-LENGTH(LP-COUNT)
     END-IF
     GOBACK.
 END PROGRAM LOCAL-PACKS-SCAN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOCAL-PACK-READ.
*> USING CLIENT-STATE, entry (LP-ENTRY with name, id and kind), root path (PIC X(1100)), root
*> length: the entry's validity, problem, description, compatibility and icon.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-ZIP                 USAGE POINTER.
 01 WS-STATUS              BINARY-LONG.
 01 WS-PROBLEM-KEY         PIC X(80).
 01 WS-KEY-LENGTH          BINARY-LONG.
 01 WS-EMPTY               PIC X(256) VALUE SPACES.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-NAME                PIC X(256).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-TEXT                PIC X(262144).
 01 WS-CAP                 BINARY-LONG VALUE 262144.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PACK-NAME           PIC X(80).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ENTRY                BINARY-LONG.
 01 L-ROOT                 PIC X(1100).
 01 L-ROOT-LENGTH          BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ENTRY L-ROOT L-ROOT-LENGTH.
     SET WS-ZIP TO NULL
     MOVE SPACES TO WS-PROBLEM-KEY
     IF LP-KIND(L-ENTRY) = 2
         CALL "ZIP-OPEN" USING L-ROOT L-ROOT-LENGTH WS-ZIP WS-STATUS
         IF WS-STATUS NOT = 0
             MOVE "cobolcraft.screen.packs.problem.unreadable" TO WS-PROBLEM-KEY
         END-IF
     END-IF
     IF WS-PROBLEM-KEY = SPACES
         MOVE "pack.mcmeta" TO WS-NAME
         MOVE 11 TO WS-NAME-LENGTH
         CALL "LOCAL-ROOT-FILE" USING WS-ZIP L-ROOT L-ROOT-LENGTH WS-NAME WS-NAME-LENGTH WS-TEXT
             WS-CAP WS-LENGTH WS-STATUS
         IF WS-STATUS NOT = 0
             MOVE "cobolcraft.screen.packs.problem.no_metadata" TO WS-PROBLEM-KEY
         ELSE
             CALL "LOCAL-PACK-META" USING CLIENT-STATE L-ENTRY WS-TEXT WS-LENGTH WS-PROBLEM-KEY
         END-IF
     END-IF
     IF WS-PROBLEM-KEY = SPACES
         MOVE 1 TO LP-VALID(L-ENTRY)
         MOVE "pack.png" TO WS-NAME
         MOVE 8 TO WS-NAME-LENGTH
         CALL "LOCAL-ROOT-FILE" USING WS-ZIP L-ROOT L-ROOT-LENGTH WS-NAME WS-NAME-LENGTH WS-TEXT
             WS-CAP WS-LENGTH WS-STATUS
         IF WS-STATUS NOT = 1
             CALL "LOCAL-PACK-ICON" USING CLIENT-STATE L-ENTRY WS-TEXT WS-LENGTH WS-STATUS
         END-IF
     ELSE
         MOVE 0 TO LP-VALID(L-ENTRY)
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PROBLEM-KEY)) TO WS-KEY-LENGTH
         MOVE LP-NAME(L-ENTRY) TO WS-PACK-NAME
         CALL "PACK-PROBLEM-TEXT" USING CLIENT-STATE WS-PACK-NAME LP-NAME-LENGTH(L-ENTRY)
             WS-PROBLEM-KEY WS-KEY-LENGTH WS-EMPTY WS-ZERO LP-PROBLEM(L-ENTRY)
             LP-PROBLEM-LENGTH(L-ENTRY)
     END-IF
     CALL "ZIP-CLOSE" USING WS-ZIP
     GOBACK.
 END PROGRAM LOCAL-PACK-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOCAL-ROOT-FILE.
*> USING zip handle (NULL for a folder), root path (PIC X(1100)), root length, name (PIC X(256)),
*> name length, area, capacity, length out, status out (0 read, 1 absent, 2 unreadable or larger
*> than the capacity): a file at the pack root.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-INDEX               BINARY-LONG.
 01 WS-PATH                PIC X(1100).
 01 WS-PATH-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 01 L-ZIP                  USAGE POINTER.
 01 L-ROOT                 PIC X(1100).
 01 L-ROOT-LENGTH          BINARY-LONG.
 01 L-NAME                 PIC X(256).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ZIP L-ROOT L-ROOT-LENGTH L-NAME L-NAME-LENGTH L-AREA L-CAPACITY
         L-LENGTH L-STATUS.
     MOVE 0 TO L-LENGTH
     IF L-ZIP NOT = NULL
         CALL "ZIP-FIND" USING L-ZIP L-NAME L-NAME-LENGTH WS-INDEX
         MOVE 1 TO L-STATUS
         IF WS-INDEX > 0
             CALL "ZIP-READ" USING L-ZIP WS-INDEX L-AREA L-CAPACITY L-LENGTH L-STATUS
             MOVE FUNCTION MIN(L-STATUS, 2) TO L-STATUS
         END-IF
     ELSE
         MOVE SPACES TO WS-PATH
         STRING L-ROOT(1:L-ROOT-LENGTH) "/" L-NAME(1:L-NAME-LENGTH) DELIMITED BY SIZE
             INTO WS-PATH
         COMPUTE WS-PATH-LENGTH = L-ROOT-LENGTH + 1 + L-NAME-LENGTH
         CALL "FILE-READ-ALL" USING WS-PATH WS-PATH-LENGTH L-AREA L-CAPACITY L-LENGTH L-STATUS
         IF L-STATUS = 5
             MOVE 2 TO L-STATUS
         END-IF
     END-IF
     GOBACK.
 END PROGRAM LOCAL-ROOT-FILE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOCAL-PACK-META.
*> USING CLIENT-STATE, entry, pack.mcmeta text (PIC X(262144)), length, problem key out (PIC X(80),
*> spaces when usable): the entry's description and compatibility.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLMCMETA.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ENTRY                BINARY-LONG.
 01 L-TEXT                 PIC X(262144).
 01 L-LENGTH               BINARY-LONG.
 01 L-KEY                  PIC X(80).
 PROCEDURE DIVISION USING CLIENT-STATE L-ENTRY L-TEXT L-LENGTH L-KEY.
     CALL "MCMETA-PARSE" USING CLIENT-STATE L-TEXT L-LENGTH PACK-META
     IF PM-VALID = 0
         MOVE "cobolcraft.screen.packs.problem.bad_metadata" TO L-KEY
     END-IF
     MOVE PM-DESC(1:256) TO LP-DESC(L-ENTRY)
     MOVE FUNCTION MIN(PM-DESC-LENGTH, 256) TO LP-DESC-LENGTH(L-ENTRY)
     MOVE PM-COMPAT TO LP-COMPAT(L-ENTRY)
     GOBACK.
 END PROGRAM LOCAL-PACK-META.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOCAL-PACK-ICON.
*> USING CLIENT-STATE, entry, pack.png bytes (PIC X(262144)), length, read status (0 read, 2
*> unreadable): the next icon cell of the UI atlas (none when the atlas does not exist yet or every
*> cell is taken) gets the image scaled to 16 x 16 (nearest pixel), or the missing texture when
*> it cannot be decoded (08 §1.2 placeholder).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 01 WS-IMAGE               PIC X(1048576).
 01 WS-IMAGE-CAP           BINARY-LONG VALUE 1048576.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-STATUS              BINARY-LONG.
 01 WS-SIXTEEN             BINARY-LONG VALUE 16.
 01 WS-SIXTEEN2            BINARY-LONG VALUE 16.
 01 WS-PER                 BINARY-LONG.
 01 WS-CX                  BINARY-LONG.
 01 WS-CY                  BINARY-LONG.
 01 WS-X                   BINARY-LONG.
 01 WS-Y                   BINARY-LONG.
 01 WS-SX                  BINARY-LONG.
 01 WS-SY                  BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 B-ATLAS                PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ENTRY                BINARY-LONG.
 01 L-DATA                 PIC X(262144).
 01 L-LENGTH               BINARY-LONG.
 01 L-READ                 BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ENTRY L-DATA L-LENGTH L-READ.
     IF UA-ADDR = NULL OR LP-ICON-COUNT >= CL-MAX-ICONS
         GOBACK
     END-IF
     MOVE 1 TO WS-STATUS
     IF L-READ = 0
         CALL "PNG-DECODE" USING L-DATA L-LENGTH WS-IMAGE WS-IMAGE-CAP WS-W WS-H WS-STATUS
     END-IF
     IF WS-STATUS NOT = 0
         MOVE 16 TO WS-W WS-H
         CALL "MISSING-TEXTURE" USING WS-SIXTEEN WS-SIXTEEN2 WS-IMAGE
     END-IF
     ADD 1 TO LP-ICON-COUNT
     MOVE LP-ICON-COUNT TO LP-ICON(L-ENTRY)
     COMPUTE WS-PER = UA-W / 16
     COMPUTE WS-CX = FUNCTION MOD(LP-ICON-COUNT - 1, WS-PER) * 16
     COMPUTE WS-CY = (LP-ICON-COUNT - 1) / WS-PER
     COMPUTE WS-CY = UA-ICON-Y + WS-CY * 16
     SET ADDRESS OF B-ATLAS TO UA-ADDR
     PERFORM VARYING WS-Y FROM 0 BY 1 UNTIL WS-Y > 15
         COMPUTE WS-SY = WS-Y * WS-H / 16
         PERFORM VARYING WS-X FROM 0 BY 1 UNTIL WS-X > 15
             COMPUTE WS-SX = WS-X * WS-W / 16
             COMPUTE WS-FROM = (WS-SY * WS-W + WS-SX) * 4 + 1
             COMPUTE WS-TO = ((WS-CY + WS-Y) * UA-W + WS-CX + WS-X) * 4 + 1
             MOVE WS-IMAGE(WS-FROM:4) TO B-ATLAS(WS-TO:4)
         END-PERFORM
     END-PERFORM
     MOVE 1 TO AT-UPLOAD(3)
     GOBACK.
 END PROGRAM LOCAL-PACK-ICON.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. LOCAL-PACK-FIND.
*> USING CLIENT-STATE, id (PIC X(80)), id length, entry out (0 = no local pack has the id).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   PIC X(80).
 01 L-LENGTH               BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-LENGTH L-ENTRY.
     MOVE 0 TO L-ENTRY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > LP-COUNT OR L-ENTRY > 0
         IF LP-ID-LENGTH(WS-I) = L-LENGTH AND LP-ID(WS-I) = L-ID
             MOVE WS-I TO L-ENTRY
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM LOCAL-PACK-FIND.
