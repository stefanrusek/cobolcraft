*> Game directory of the client (contracts/client-surface.md §2): GAME-DIR-SETUP creates it and its
*> resourcepacks/, saves/ and downloads/ directories; SERVERS-LOAD and SERVERS-SAVE read and write
*> servers.dat (gzip NBT: List "Servers" of {Name, Address, PackPolicy}) through proto NBT-FILE-READ
*> and NBT-FILE-WRITE. Single-player worlds (US16): WORLD-FOLDER-NAME names a new world's folder,
*> WORLDS-LIST reads the world list from saves/, WORLD-DELETE deletes a world folder. Packs (US18-2):
*> OPTIONS-LOAD and OPTIONS-SAVE read and write options.dat (gzip NBT: List "EnabledPacks" of
*> String, top first). A data file that cannot be read, or written, is fatal (research R14):
*> "FATAL client data: <path>: cannot be read" / "... cannot be written".

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-DIR-SETUP.
*> USING CLIENT-STATE: creates every missing directory of CL-GAME-DIR (one path component at a
*> time), then its three subdirectories.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-PATH                PIC X(1100).
 01 WS-I                   BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     PERFORM VARYING WS-I FROM 2 BY 1 UNTIL WS-I > CL-GAME-DIR-LENGTH
         IF CL-GAME-DIR(WS-I:1) = "/"
             MOVE SPACES TO WS-PATH
             MOVE CL-GAME-DIR(1:WS-I - 1) TO WS-PATH
             CALL "CBL_CREATE_DIR" USING WS-PATH
         END-IF
     END-PERFORM
     MOVE SPACES TO WS-PATH
     MOVE CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) TO WS-PATH
     CALL "CBL_CREATE_DIR" USING WS-PATH
     MOVE SPACES TO WS-PATH
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/resourcepacks" DELIMITED BY SIZE INTO WS-PATH
     CALL "CBL_CREATE_DIR" USING WS-PATH
     MOVE SPACES TO WS-PATH
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/saves" DELIMITED BY SIZE INTO WS-PATH
     CALL "CBL_CREATE_DIR" USING WS-PATH
     MOVE SPACES TO WS-PATH
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/downloads" DELIMITED BY SIZE INTO WS-PATH
     CALL "CBL_CREATE_DIR" USING WS-PATH
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM GAME-DIR-SETUP.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-DATA-PATH.
*> USING CLIENT-STATE, file name (PIC X(32)), path out (PIC X(1100)), path length out:
*> <game directory>/<file name>.
 DATA DIVISION.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-FILE                 PIC X(32).
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-FILE L-PATH L-LENGTH.
     MOVE SPACES TO L-PATH
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/" FUNCTION TRIM(L-FILE) DELIMITED BY SIZE
         INTO L-PATH
     COMPUTE L-LENGTH = CL-GAME-DIR-LENGTH + 1 + FUNCTION LENGTH(FUNCTION TRIM(L-FILE))
     GOBACK.
 END PROGRAM GAME-DATA-PATH.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. GAME-DATA-CHECK.
*> USING outcome (BINARY-LONG), path (PIC X(1100)), path length, problem (PIC X(32)): when the
*> outcome is not 0, "client data: <path>: <problem>" through cc_fatal (does not return). The fatal
*> call stays in this small program: a run that ends inside a program leaves gcov's derived line
*> counts of that program inconsistent.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-WHAT                PIC X(1200).
 LINKAGE SECTION.
 01 L-OUTCOME              BINARY-LONG.
 01 L-PATH                 PIC X(1100).
 01 L-LENGTH               BINARY-LONG.
 01 L-PROBLEM              PIC X(32).
 PROCEDURE DIVISION USING L-OUTCOME L-PATH L-LENGTH L-PROBLEM.
     IF L-OUTCOME NOT = 0
         MOVE LOW-VALUES TO WS-WHAT
         STRING "client data: " L-PATH(1:L-LENGTH) ": " FUNCTION TRIM(L-PROBLEM)
             DELIMITED BY SIZE INTO WS-WHAT
         CALL STATIC "cc_fatal" USING BY REFERENCE WS-WHAT
     END-IF
     GOBACK.
 END PROGRAM GAME-DATA-CHECK.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SERVERS-LOAD.
*> USING CLIENT-STATE: the server list from servers.dat (empty when the file does not exist; at most
*> CL-MAX-SERVERS entries; other tags are skipped). Unreadable: fatal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY CLCONST.
 01 WS-FILE                PIC X(32) VALUE "servers.dat".
 01 WS-PROBLEM             PIC X(32) VALUE "cannot be read".
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-INFO                PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FILE-FRAMING        BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WN                     PIC X(64).
 01 WN-CAP                 BINARY-LONG VALUE 64.
 01 WL                     BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-TEXT-CAP            BINARY-LONG VALUE 256.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO SL-COUNT
     CALL "GAME-DATA-PATH" USING CLIENT-STATE WS-FILE WS-PATH WS-LENGTH
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     IF RETURN-CODE NOT = 0
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBT-FILE-READ" USING WS-PATH WS-LENGTH PB-BUFFER WS-OUTCOME
     CALL "GAME-DATA-CHECK" USING WS-OUTCOME WS-PATH WS-LENGTH WS-PROBLEM
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FILE-FRAMING WS-TYPE
     MOVE 1 TO WS-TYPE
     PERFORM UNTIL WS-TYPE = 0
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WN-CAP WL
         EVALUATE TRUE
             WHEN WS-TYPE = 0
                 CONTINUE
             WHEN WN = "Servers" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                     IF WS-ETYPE = 10 AND SL-COUNT < CL-MAX-SERVERS
                         ADD 1 TO SL-COUNT
                         INITIALIZE SL-ENTRY(SL-COUNT)
                         PERFORM UNTIL WS-ETYPE = 0
                             MOVE SPACES TO WN
                             CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-ETYPE WN WN-CAP WL
                             EVALUATE TRUE
                                 WHEN WS-ETYPE = 0
                                     CONTINUE
                                 WHEN WN = "Name" AND WS-ETYPE = 8
                                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAP
                                         WS-TEXT-LENGTH
                                     MOVE WS-TEXT(1:64) TO SL-NAME(SL-COUNT)
                                     MOVE FUNCTION MIN(WS-TEXT-LENGTH, 64)
                                         TO SL-NAME-LENGTH(SL-COUNT)
                                 WHEN WN = "Address" AND WS-ETYPE = 8
                                     CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAP
                                         WS-TEXT-LENGTH
                                     MOVE WS-TEXT TO SL-ADDR(SL-COUNT)
                                     MOVE WS-TEXT-LENGTH TO SL-ADDR-LENGTH(SL-COUNT)
                                 WHEN WN = "PackPolicy" AND WS-ETYPE = 3
                                     CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                                     MOVE WS-INT TO SL-POLICY(SL-COUNT)
                                 WHEN OTHER
                                     CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
                             END-EVALUATE
                         END-PERFORM
                         MOVE 10 TO WS-ETYPE
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM SERVERS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. SERVERS-SAVE.
*> USING CLIENT-STATE: writes servers.dat from the server list. A failed write is fatal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-FILE                PIC X(32) VALUE "servers.dat".
 01 WS-PROBLEM             PIC X(32) VALUE "cannot be written".
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-COMPOUND            BINARY-LONG VALUE 10.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-I                   BINARY-LONG.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "GAME-DATA-PATH" USING CLIENT-STATE WS-FILE WS-PATH WS-LENGTH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "Servers" TO WN
     MOVE 7 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-COMPOUND SL-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > SL-COUNT
         CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WS-ELEMENT
         MOVE "Name" TO WN
         MOVE 4 TO WL
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL SL-NAME(WS-I) SL-NAME-LENGTH(WS-I)
         MOVE "Address" TO WN
         MOVE 7 TO WL
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WL SL-ADDR(WS-I) SL-ADDR-LENGTH(WS-I)
         MOVE "PackPolicy" TO WN
         MOVE 10 TO WL
         CALL "NBT-WRITE-INT" USING PB-BUFFER WN WL SL-POLICY(WS-I)
         CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-FILE-WRITE" USING WS-PATH WS-LENGTH PB-BUFFER WS-OUTCOME
     CALL "GAME-DATA-CHECK" USING WS-OUTCOME WS-PATH WS-LENGTH WS-PROBLEM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM SERVERS-SAVE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-FOLDER-NAME.
*> USING CLIENT-STATE, world name (PIC X(64)), name length, folder out (PIC X(80)), folder length
*> out: the single-player folder of a new world (client-surface §2): the name with every character
*> outside A-Z a-z 0-9 _ - space replaced by _ (one _ for each UTF-8 character); when saves/ has
*> that folder already, " (2)", " (3)", ... is appended until it does not.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-BASE                PIC X(64).
 01 WS-BASE-LENGTH         BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   PIC X.
 01 WS-N                   BINARY-LONG.
 01 WS-EDIT                PIC Z(9)9.
 01 WS-PATH                PIC X(1200).
 01 WS-INFO                PIC X(16).
 01 WS-EXISTS              BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-NAME                 PIC X(64).
 01 L-NAME-LENGTH          BINARY-LONG.
 01 L-FOLDER               PIC X(80).
 01 L-FOLDER-LENGTH        BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-NAME L-NAME-LENGTH L-FOLDER L-FOLDER-LENGTH.
     MOVE SPACES TO WS-BASE
     MOVE 0 TO WS-BASE-LENGTH
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > L-NAME-LENGTH
         MOVE L-NAME(WS-I:1) TO WS-C
         COMPUTE WS-B = FUNCTION ORD(WS-C) - 1
         EVALUATE TRUE
             WHEN WS-B >= 128 AND WS-B < 192
                 CONTINUE
             WHEN (WS-C >= "A" AND WS-C <= "Z") OR (WS-C >= "a" AND WS-C <= "z")
                     OR (WS-C >= "0" AND WS-C <= "9") OR WS-C = "_" OR WS-C = "-" OR WS-C = " "
                 ADD 1 TO WS-BASE-LENGTH
                 MOVE WS-C TO WS-BASE(WS-BASE-LENGTH:1)
             WHEN OTHER
                 ADD 1 TO WS-BASE-LENGTH
                 MOVE "_" TO WS-BASE(WS-BASE-LENGTH:1)
         END-EVALUATE
     END-PERFORM
     MOVE SPACES TO L-FOLDER
     MOVE WS-BASE TO L-FOLDER
     MOVE WS-BASE-LENGTH TO L-FOLDER-LENGTH
     MOVE 1 TO WS-N WS-EXISTS
     PERFORM UNTIL WS-EXISTS = 0
         IF WS-N > 1
             MOVE WS-N TO WS-EDIT
             MOVE SPACES TO L-FOLDER
             STRING WS-BASE(1:WS-BASE-LENGTH) " (" FUNCTION TRIM(WS-EDIT) ")" DELIMITED BY SIZE
                 INTO L-FOLDER
             COMPUTE L-FOLDER-LENGTH = WS-BASE-LENGTH + 3
                 + FUNCTION LENGTH(FUNCTION TRIM(WS-EDIT))
         END-IF
         MOVE SPACES TO WS-PATH
         STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/saves/" L-FOLDER(1:L-FOLDER-LENGTH)
             DELIMITED BY SIZE INTO WS-PATH
         CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
         MOVE RETURN-CODE TO WS-EXISTS
         IF WS-EXISTS = 0
             MOVE 1 TO WS-EXISTS
             ADD 1 TO WS-N
         ELSE
             MOVE 0 TO WS-EXISTS
         END-IF
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM WORLD-FOLDER-NAME.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLDS-LIST.
*> USING CLIENT-STATE: the world list from the directories of saves/ (cc_fs_list, byte order; at
*> most CL-MAX-WORLDS): each folder's level.dat gives LevelName, GameMode (07 §9.2) and WorldType
*> (world-types.md §2.1; a world with none is a cobolcraft world, rule 2); a folder
*> whose level.dat cannot be read shows its folder name, survival.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLCONST.
 COPY PROTO.
 01 WS-DIRZ                PIC X(1200).
 01 WS-LIST                PIC X(65536).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-PATH                PIC X(1200).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FILE-FRAMING        BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WN                     PIC X(64).
 01 WN-CAP                 BINARY-LONG VALUE 64.
 01 WL                     BINARY-LONG.
 01 WS-TEXT                PIC X(256).
 01 WS-TEXT-CAP            BINARY-LONG VALUE 256.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 01 WS-INT                 BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO WL-COUNT
     MOVE LOW-VALUES TO WS-DIRZ
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/saves" DELIMITED BY SIZE INTO WS-DIRZ
     MOVE 0 TO WS-LIST-COUNT
     CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
         BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE 1 TO WS-PTR
     PERFORM WS-LIST-COUNT TIMES
         MOVE SPACES TO WS-ENTRY
         UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY COUNT IN WS-LENGTH
             WITH POINTER WS-PTR
         IF WS-ENTRY(1:1) = "D" AND WL-COUNT < CL-MAX-WORLDS AND WS-LENGTH <= 81
             ADD 1 TO WL-COUNT
             MOVE SPACES TO WL-FOLDER(WL-COUNT)
             MOVE WS-ENTRY(2:80) TO WL-FOLDER(WL-COUNT)
             COMPUTE WL-FOLDER-LENGTH(WL-COUNT) = WS-LENGTH - 1
             MOVE WL-FOLDER(WL-COUNT) TO WL-NAME(WL-COUNT)
             MOVE FUNCTION MIN(WL-FOLDER-LENGTH(WL-COUNT), 64) TO WL-NAME-LENGTH(WL-COUNT)
             MOVE 0 TO WL-MODE(WL-COUNT)
             MOVE "cobolcraft" TO WL-TYPE(WL-COUNT)
             MOVE SPACES TO WS-PATH
             STRING WS-DIRZ(1:CL-GAME-DIR-LENGTH + 6) "/" WS-ENTRY(2:WS-LENGTH - 1) "/level.dat"
                 DELIMITED BY SIZE INTO WS-PATH
             COMPUTE WS-PATH-LENGTH = CL-GAME-DIR-LENGTH + WS-LENGTH + 16
             CALL "PB-RESET" USING PB-BUFFER
             CALL "NBT-FILE-READ" USING WS-PATH WS-PATH-LENGTH PB-BUFFER WS-OUTCOME
             MOVE 1 TO WS-TYPE
             IF WS-OUTCOME = 0
                 CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FILE-FRAMING WS-TYPE
             END-IF
             PERFORM UNTIL WS-OUTCOME NOT = 0 OR WS-TYPE = 0
                 MOVE SPACES TO WN
                 CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WN-CAP WL
                 EVALUATE TRUE
                     WHEN WS-TYPE = 0
                         CONTINUE
                     WHEN WN = "LevelName" AND WS-TYPE = 8
                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAP
                             WS-TEXT-LENGTH
                         MOVE WS-TEXT(1:64) TO WL-NAME(WL-COUNT)
                         MOVE FUNCTION MIN(WS-TEXT-LENGTH, 64) TO WL-NAME-LENGTH(WL-COUNT)
                     WHEN WN = "WorldType" AND WS-TYPE = 8
                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAP
                             WS-TEXT-LENGTH
                         MOVE SPACES TO WL-TYPE(WL-COUNT)
                         MOVE WS-TEXT(1:16) TO WL-TYPE(WL-COUNT)
                     WHEN WN = "GameMode" AND WS-TYPE = 3
                         CALL "PB-GET-INT" USING PB-BUFFER WS-INT
                         MOVE WS-INT TO WL-MODE(WL-COUNT)
                     WHEN OTHER
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 END-EVALUATE
             END-PERFORM
         END-IF
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM WORLDS-LIST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. WORLD-DELETE.
*> USING CLIENT-STATE, folder (PIC X(80), under saves/), folder length: deletes the world folder
*> with everything in it (cc_fs_list, CBL_DELETE_FILE, CBL_DELETE_DIR), depth first without
*> recursion: a stack of directory paths; a directory is listed, its files deleted, its first
*> subdirectory pushed; one without subdirectories is deleted and popped. A directory that cannot
*> be deleted (deeper than 32 levels, or not emptied) is a non-fatal failure: "ERROR world: <path>
*> cannot be deleted" and the deletion stops (FR-012).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-STACK.
    05 WS-DIR OCCURS 32 TIMES.
       10 WS-DIR-PATH      PIC X(1200).
       10 WS-DIR-LENGTH    BINARY-LONG.
 01 WS-DEPTH               BINARY-LONG.
 01 WS-DIRZ                PIC X(1200).
 01 WS-LIST                PIC X(65536).
 01 WS-LIST-CAPACITY       BINARY-LONG VALUE 65536.
 01 WS-LIST-COUNT          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-ENTRY               PIC X(256).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-SUB                 PIC X(256).
 01 WS-SUB-LENGTH          BINARY-LONG.
 01 WS-CUR                 PIC X(1200).
 01 WS-CUR-LENGTH          BINARY-LONG.
 01 WS-PATH                PIC X(1200).
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-FOLDER               PIC X(80).
 01 L-FOLDER-LENGTH        BINARY-LONG.
 PROCEDURE DIVISION USING CLIENT-STATE L-FOLDER L-FOLDER-LENGTH.
     MOVE 1 TO WS-DEPTH
     MOVE SPACES TO WS-DIR-PATH(1)
     STRING CL-GAME-DIR(1:CL-GAME-DIR-LENGTH) "/saves/" L-FOLDER(1:L-FOLDER-LENGTH)
         DELIMITED BY SIZE INTO WS-DIR-PATH(1)
     COMPUTE WS-DIR-LENGTH(1) = CL-GAME-DIR-LENGTH + 7 + L-FOLDER-LENGTH
     PERFORM UNTIL WS-DEPTH = 0
         MOVE WS-DIR-PATH(WS-DEPTH) TO WS-CUR
         MOVE WS-DIR-LENGTH(WS-DEPTH) TO WS-CUR-LENGTH
         MOVE LOW-VALUES TO WS-DIRZ
         MOVE WS-CUR(1:WS-CUR-LENGTH) TO WS-DIRZ(1:WS-CUR-LENGTH)
         MOVE 0 TO WS-LIST-COUNT WS-SUB-LENGTH
         CALL STATIC "cc_fs_list" USING BY REFERENCE WS-DIRZ BY REFERENCE WS-LIST
             BY VALUE WS-LIST-CAPACITY BY REFERENCE WS-LIST-COUNT RETURNING WS-RC
         MOVE 1 TO WS-PTR
         PERFORM WS-LIST-COUNT TIMES
             MOVE SPACES TO WS-ENTRY
             UNSTRING WS-LIST DELIMITED BY X"0A" INTO WS-ENTRY COUNT IN WS-LENGTH
                 WITH POINTER WS-PTR
             EVALUATE TRUE
                 WHEN WS-ENTRY(1:1) = "F"
                     MOVE SPACES TO WS-PATH
                     STRING WS-CUR(1:WS-CUR-LENGTH) "/" WS-ENTRY(2:WS-LENGTH - 1)
                         DELIMITED BY SIZE INTO WS-PATH
                     CALL "CBL_DELETE_FILE" USING WS-PATH
                 WHEN WS-SUB-LENGTH = 0
                     MOVE WS-ENTRY(2:255) TO WS-SUB
                     COMPUTE WS-SUB-LENGTH = WS-LENGTH - 1
             END-EVALUATE
         END-PERFORM
         IF WS-SUB-LENGTH > 0 AND WS-DEPTH < 32
             ADD 1 TO WS-DEPTH
             MOVE SPACES TO WS-DIR-PATH(WS-DEPTH)
             STRING WS-CUR(1:WS-CUR-LENGTH) "/" WS-SUB(1:WS-SUB-LENGTH) DELIMITED BY SIZE
                 INTO WS-DIR-PATH(WS-DEPTH)
             COMPUTE WS-DIR-LENGTH(WS-DEPTH) = WS-CUR-LENGTH + 1 + WS-SUB-LENGTH
         ELSE
             CALL "CBL_DELETE_DIR" USING WS-CUR
             SUBTRACT 1 FROM WS-DEPTH
             IF RETURN-CODE NOT = 0
                 DISPLAY "ERROR world: " WS-CUR(1:WS-CUR-LENGTH) " cannot be deleted"
                 MOVE 0 TO WS-DEPTH
             END-IF
         END-IF
     END-PERFORM
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM WORLD-DELETE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-LOAD.
*> USING CLIENT-STATE: the enabled pack ids (OP-ENABLED, top first) from options.dat (none when the
*> file does not exist; at most CL-MAX-LOCAL-PACKS; other tags are skipped). Unreadable: fatal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY CLCONST.
 01 WS-FILE                PIC X(32) VALUE "options.dat".
 01 WS-PROBLEM             PIC X(32) VALUE "cannot be read".
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-INFO                PIC X(16).
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-FILE-FRAMING        BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ETYPE               BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WN                     PIC X(64).
 01 WN-CAP                 BINARY-LONG VALUE 64.
 01 WL                     BINARY-LONG.
 01 WS-TEXT                PIC X(80).
 01 WS-TEXT-CAP            BINARY-LONG VALUE 80.
 01 WS-TEXT-LENGTH         BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     MOVE 0 TO OP-COUNT
     CALL "GAME-DATA-PATH" USING CLIENT-STATE WS-FILE WS-PATH WS-LENGTH
     CALL "CBL_CHECK_FILE_EXIST" USING WS-PATH WS-INFO
     IF RETURN-CODE NOT = 0
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "NBT-FILE-READ" USING WS-PATH WS-LENGTH PB-BUFFER WS-OUTCOME
     CALL "GAME-DATA-CHECK" USING WS-OUTCOME WS-PATH WS-LENGTH WS-PROBLEM
     CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FILE-FRAMING WS-TYPE
     MOVE 1 TO WS-TYPE
     PERFORM UNTIL WS-TYPE = 0
         MOVE SPACES TO WN
         CALL "NBT-READ-COMPOUND-NEXT" USING PB-BUFFER WS-TYPE WN WN-CAP WL
         EVALUATE TRUE
             WHEN WS-TYPE = 0
                 CONTINUE
             WHEN WN = "EnabledPacks" AND WS-TYPE = 9
                 CALL "NBT-READ-LIST-BEGIN" USING PB-BUFFER WS-ETYPE WS-COUNT
                 PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-COUNT
                     IF WS-ETYPE = 8 AND OP-COUNT < CL-MAX-LOCAL-PACKS
                         MOVE SPACES TO WS-TEXT
                         CALL "NBT-READ-STRING" USING PB-BUFFER WS-TEXT WS-TEXT-CAP
                             WS-TEXT-LENGTH
                         ADD 1 TO OP-COUNT
                         MOVE WS-TEXT TO OP-ID(OP-COUNT)
                         MOVE WS-TEXT-LENGTH TO OP-ID-LENGTH(OP-COUNT)
                     ELSE
                         CALL "NBT-READ-SKIP" USING PB-BUFFER WS-ETYPE
                     END-IF
                 END-PERFORM
             WHEN OTHER
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
         END-EVALUATE
     END-PERFORM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM OPTIONS-LOAD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. OPTIONS-SAVE.
*> USING CLIENT-STATE: writes options.dat from the enabled pack ids. A failed write is fatal.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-FILE                PIC X(32) VALUE "options.dat".
 01 WS-PROBLEM             PIC X(32) VALUE "cannot be written".
 01 WS-PATH                PIC X(1100).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-STRING              BINARY-LONG VALUE 8.
 01 WS-ELEMENT             BINARY-LONG VALUE -1.
 01 WS-I                   BINARY-LONG.
 01 WN                     PIC X(16).
 01 WL                     BINARY-LONG.
 LINKAGE SECTION.
 COPY CLSTATE.
 PROCEDURE DIVISION USING CLIENT-STATE.
     CALL "GAME-DATA-PATH" USING CLIENT-STATE WS-FILE WS-PATH WS-LENGTH
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     MOVE SPACES TO WN
     MOVE 0 TO WL
     CALL "NBT-WRITE-COMPOUND-BEGIN" USING PB-BUFFER WN WL
     MOVE "EnabledPacks" TO WN
     MOVE 12 TO WL
     CALL "NBT-WRITE-LIST-BEGIN" USING PB-BUFFER WN WL WS-STRING OP-COUNT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > OP-COUNT
         CALL "NBT-WRITE-STRING" USING PB-BUFFER WN WS-ELEMENT OP-ID(WS-I) OP-ID-LENGTH(WS-I)
     END-PERFORM
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     CALL "NBT-FILE-WRITE" USING WS-PATH WS-LENGTH PB-BUFFER WS-OUTCOME
     CALL "GAME-DATA-CHECK" USING WS-OUTCOME WS-PATH WS-LENGTH WS-PROBLEM
     CALL "PB-FREE" USING PB-BUFFER
     GOBACK.
 END PROGRAM OPTIONS-SAVE.
