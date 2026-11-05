*> Standalone gzip NBT files (docs/protocol/07-nbt-and-anvil.md §5.1; contracts/proto-api.md §2
*> "NBT files"): the one gzip NBT file path shared by core (world folder) and client (servers.dat,
*> options.dat, reading level.dat). Bytes go through GnuCOBOL CBL_* byte-stream routines and
*> cc_deflate / cc_inflate mode CC_GZIP (research R2; shim-abi §5). The path is given as an area and
*> a byte length (no trailing spaces).

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBT-FILE-WRITE.
*> USING path (any area), path length (BINARY-LONG), PB-BUFFER (a named-root NBT stream, bytes 1 to
*> PB-LENGTH: a compound written with name length 0), outcome out (BINARY-LONG 0 written, 1 the file
*> could not be created or written; the caller applies research R14). The file is replaced.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-FILENAME            PIC X(4096).
 01 WS-ACCESS              PIC X COMP-X VALUE 2.
 01 WS-DENY                PIC X COMP-X VALUE 0.
 01 WS-DEVICE              PIC X COMP-X VALUE 0.
 01 WS-HANDLE              PIC X(4).
 01 WS-OFFSET              PIC X(8) COMP-X.
 01 WS-COUNT               PIC X(4) COMP-X.
 01 WS-FLAGS               BINARY-CHAR UNSIGNED VALUE 0.
 01 WS-MODE                BINARY-LONG VALUE CC-GZIP.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-OUT-ADDR            USAGE POINTER.
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-DEFLATE-RC          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-CLOSE-RC            BINARY-LONG.
 01 B-PATH                 PIC X(4096) BASED.
 01 B-OUT                  PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PATH                 PIC X.
 01 L-PATH-LENGTH          BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-PATH-LENGTH PB-BUFFER L-OUTCOME.
     SET ADDRESS OF B-PATH TO ADDRESS OF L-PATH
     MOVE SPACES TO WS-FILENAME
     MOVE B-PATH(1:L-PATH-LENGTH) TO WS-FILENAME
     COMPUTE WS-CAPACITY = PB-LENGTH + PB-LENGTH / 1000 + 64
     ALLOCATE WS-CAPACITY CHARACTERS RETURNING WS-OUT-ADDR
     SET ADDRESS OF B-OUT TO WS-OUT-ADDR
     CALL STATIC "cc_deflate" USING BY VALUE WS-MODE BY VALUE PB-ADDR BY VALUE PB-LENGTH
         BY VALUE WS-OUT-ADDR BY VALUE WS-CAPACITY BY REFERENCE WS-OUT-LENGTH
         RETURNING WS-DEFLATE-RC
     CALL "CBL_CREATE_FILE" USING WS-FILENAME WS-ACCESS WS-DENY WS-DEVICE WS-HANDLE
         RETURNING WS-RC
     IF WS-RC NOT = 0
         MOVE 1 TO L-OUTCOME
     ELSE
         MOVE 0 TO WS-OFFSET
         MOVE WS-OUT-LENGTH TO WS-COUNT
         CALL "CBL_WRITE_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS B-OUT
             RETURNING WS-RC
         CALL "CBL_CLOSE_FILE" USING WS-HANDLE RETURNING WS-CLOSE-RC
         COMPUTE L-OUTCOME = FUNCTION MIN(1, FUNCTION ABS(WS-DEFLATE-RC) + FUNCTION ABS(WS-RC)
             + FUNCTION ABS(WS-CLOSE-RC))
     END-IF
     FREE WS-OUT-ADDR
     GOBACK.
 END PROGRAM NBT-FILE-WRITE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. NBT-FILE-READ.
*> USING path (any area), path length (BINARY-LONG), PB-BUFFER (initialised by the caller), outcome
*> out (BINARY-LONG). 0: the buffer holds the uncompressed named-root NBT stream, PB-POS 0, ready for
*> NBT-READ-ROOT with file framing. 1: unreadable or corrupt (missing, not gzip, not a named
*> compound root, or a malformed tree); the caller applies research R14.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 01 WS-FILENAME            PIC X(4096).
 01 WS-ACCESS              PIC X COMP-X VALUE 1.
 01 WS-DENY                PIC X COMP-X VALUE 0.
 01 WS-DEVICE              PIC X COMP-X VALUE 0.
 01 WS-HANDLE              PIC X(4).
 01 WS-OFFSET              PIC X(8) COMP-X.
 01 WS-COUNT               PIC X(4) COMP-X.
 01 WS-FLAGS               BINARY-CHAR UNSIGNED.
 01 WS-DUMMY               PIC X.
 01 WS-SIZE                BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE CC-GZIP.
 01 WS-FILE-FRAMING        BINARY-LONG VALUE 1.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TRAILER             PIC X(4).
 01 WS-ISIZE REDEFINES WS-TRAILER BINARY-LONG UNSIGNED.
 01 WS-CAPACITY            BINARY-LONG.
 01 WS-IN-ADDR             USAGE POINTER.
 01 WS-OUT-ADDR            USAGE POINTER.
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-READ-RC             BINARY-LONG.
 01 B-PATH                 PIC X(4096) BASED.
 01 B-IN                   PIC X(1073741824) BASED.
 01 B-OUT                  PIC X(1073741824) BASED.
 LINKAGE SECTION.
 COPY PROTO.
 01 L-PATH                 PIC X.
 01 L-PATH-LENGTH          BINARY-LONG.
 01 L-OUTCOME              BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-PATH-LENGTH PB-BUFFER L-OUTCOME.
     SET ADDRESS OF B-PATH TO ADDRESS OF L-PATH
     MOVE SPACES TO WS-FILENAME
     MOVE B-PATH(1:L-PATH-LENGTH) TO WS-FILENAME
     MOVE 1 TO L-OUTCOME
     CALL "CBL_OPEN_FILE" USING WS-FILENAME WS-ACCESS WS-DENY WS-DEVICE WS-HANDLE
         RETURNING WS-RC
     IF WS-RC = 0
         MOVE 0 TO WS-OFFSET WS-COUNT
         MOVE 128 TO WS-FLAGS
         CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS WS-DUMMY
             RETURNING WS-RC
         MOVE WS-OFFSET TO WS-SIZE
         MOVE 0 TO WS-FLAGS
*>       The smallest gzip member is 18 bytes (10-byte header, empty deflate block, 8-byte trailer).
*>       The output is sized from the trailer's ISIZE (capped at 256 MiB; a larger or mismatching
*>       stream fails as corrupt), then the named compound root and its whole tree are checked.
         IF WS-SIZE >= 18
             ALLOCATE WS-SIZE CHARACTERS RETURNING WS-IN-ADDR
             SET ADDRESS OF B-IN TO WS-IN-ADDR
             MOVE 0 TO WS-OFFSET
             MOVE WS-SIZE TO WS-COUNT
             CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS B-IN
                 RETURNING WS-READ-RC
             MOVE B-IN(WS-SIZE - 3:4) TO WS-TRAILER
             COMPUTE WS-CAPACITY = FUNCTION MIN(FUNCTION MAX(WS-ISIZE, 1), 268435456)
             ALLOCATE WS-CAPACITY CHARACTERS RETURNING WS-OUT-ADDR
             SET ADDRESS OF B-OUT TO WS-OUT-ADDR
             CALL STATIC "cc_inflate" USING BY VALUE WS-MODE BY VALUE WS-IN-ADDR BY VALUE WS-SIZE
                 BY VALUE WS-OUT-ADDR BY VALUE WS-CAPACITY BY REFERENCE WS-OUT-LENGTH
                 RETURNING WS-RC
             IF WS-READ-RC = 0 AND WS-RC = 0
                 CALL "PB-RESET" USING PB-BUFFER
                 CALL "PB-APPEND-BYTES" USING PB-BUFFER B-OUT WS-OUT-LENGTH
                 CALL "NBT-READ-ROOT" USING PB-BUFFER WS-FILE-FRAMING WS-TYPE
                 CALL "NBT-READ-SKIP" USING PB-BUFFER WS-TYPE
                 IF PB-ERROR = 0
                     MOVE 0 TO L-OUTCOME PB-POS
                 END-IF
             END-IF
             FREE WS-IN-ADDR
             FREE WS-OUT-ADDR
         END-IF
         CALL "CBL_CLOSE_FILE" USING WS-HANDLE
     END-IF
     GOBACK.
 END PROGRAM NBT-FILE-READ.
