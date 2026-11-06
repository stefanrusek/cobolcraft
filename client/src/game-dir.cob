*> Game directory of the client (contracts/client-surface.md §2): GAME-DIR-SETUP creates it and its
*> resourcepacks/, saves/ and downloads/ directories; SERVERS-LOAD and SERVERS-SAVE read and write
*> servers.dat (gzip NBT: List "Servers" of {Name, Address, PackPolicy}) through proto NBT-FILE-READ
*> and NBT-FILE-WRITE. A data file that cannot be read, or written, is fatal (research R14):
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
