*> The path, file and uuid helpers of the world folder (split from the old persistence.cob; the folder's layout is described at WORLD-SAVE in persist-world.cob).

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
