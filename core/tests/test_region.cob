*> Implementation test of the Anvil region files (core/src/region.cob; docs/protocol/07-nbt-and-anvil.md
*> §6, §5.2): REGION-WRITE puts a chunk payload (zlib, compression id 2) into r.<rx>.<rz>.mca with
*> the 8192-byte header (location entry: sector offset and count, timestamp: seconds since the epoch),
*> padded to whole 4096-byte sectors; REGION-READ gives the payload back. Absent chunks (no file, a
*> zero location entry, an entry overlapping the header or past the end of the file, a zero or
*> truncated length, a payload that does not inflate, a header shorter than 8192 bytes) read as
*> absent. A chunk that grows past its sectors moves to the end of the file; one that still fits is
*> rewritten in place. Expected bytes are computed here from 07 §6, not by the code under test.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-REGION.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CCSHIM.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==RB-==.
 01 WS-COMMAND             PIC X(128) VALUE
     "rm -rf build/core-test-region && mkdir -p build/core-test-region".
 01 WS-DIR                 PIC X(64) VALUE "build/core-test-region".
 01 WS-DIR-LENGTH          BINARY-LONG VALUE 22.
 01 WS-CAPACITY            BINARY-LONG VALUE 65536.
 01 WS-CX                  BINARY-LONG.
 01 WS-CZ                  BINARY-LONG.
 01 WS-OUTCOME             BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-SEED                BINARY-LONG.
 01 WS-R                   FLOAT-LONG.
 01 WS-BYTE                BINARY-CHAR UNSIGNED.
 01 WS-BYTE-X REDEFINES WS-BYTE PIC X.
 01 WS-A                   PIC X(300).
 01 WS-A-LENGTH            BINARY-LONG VALUE 300.
 01 WS-B                   PIC X(40) VALUE "a second, small chunk payload (1, 0)".
 01 WS-B-LENGTH            BINARY-LONG VALUE 40.
 01 WS-C                   PIC X(9000).
 01 WS-C-LENGTH            BINARY-LONG VALUE 9000.
 01 WS-EDIT                PIC -(10)9.
 01 WS-TEXT                PIC X(1024).
*> The raw bytes of a region file (read with the CBL_* routines).
 01 WS-FILE-NAME           PIC X(128).
 01 WS-FILE                PIC X(65536).
 01 WS-FILE-SIZE           BINARY-LONG.
 01 WS-HANDLE              PIC X(4).
 01 WS-READ-ACCESS         PIC X COMP-X VALUE 1.
 01 WS-WRITE-ACCESS        PIC X COMP-X VALUE 2.
 01 WS-DENY                PIC X COMP-X VALUE 0.
 01 WS-DEVICE              PIC X COMP-X VALUE 0.
 01 WS-OFFSET              PIC X(8) COMP-X.
 01 WS-COUNT               PIC X(4) COMP-X.
 01 WS-FLAGS               BINARY-CHAR UNSIGNED.
 01 WS-DUMMY               PIC X.
*> A big-endian Int of the file.
 01 WS-AT                  BINARY-LONG.
 01 WS-INT                 BINARY-DOUBLE.
 01 WS-Q                   BINARY-DOUBLE.
 01 WS-Q2                  BINARY-DOUBLE.
*> Independent inflate of a payload.
 01 WS-MODE                BINARY-LONG VALUE 0.
 01 WS-INFLATED            PIC X(16384).
 01 WS-INFLATED-CAPACITY   BINARY-LONG VALUE 16384.
 01 WS-INFLATED-LENGTH     BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-IN-LENGTH           BINARY-LONG.
 PROCEDURE DIVISION.
     CALL "SYSTEM" USING WS-COMMAND
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "PB-INIT" USING RB-BUFFER WS-CAPACITY
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 300
         MOVE FUNCTION CHAR(FUNCTION MOD(WS-I, 7) + 66) TO WS-A(WS-I:1)
     END-PERFORM
     MOVE 12345 TO WS-SEED
     COMPUTE WS-R = FUNCTION RANDOM(WS-SEED)
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 9000
         COMPUTE WS-BYTE = FUNCTION RANDOM * 256
         MOVE WS-BYTE-X TO WS-C(WS-I:1)
     END-PERFORM

*>   A first write: one sector at sector 2, the file padded to 3 sectors.
     MOVE 0 TO WS-CX WS-CZ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-A WS-A-LENGTH
     CALL "REGION-WRITE" USING WS-DIR WS-DIR-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     MOVE "test region write of chunk (0, 0): outcome 0, file r.0.0.mca of 12288 bytes, location "
         & "entry 0 = offset 2 count 1, timestamp after 2020" TO TL-CASE
     MOVE "build/core-test-region/r.0.0.mca" TO WS-FILE-NAME
     PERFORM READ-FILE
     MOVE SPACES TO WS-TEXT
     MOVE WS-OUTCOME TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-FILE-SIZE TO WS-EDIT
     PERFORM ADD-EDIT
     MOVE 0 TO WS-AT
     PERFORM GET-INT
     COMPUTE WS-EDIT = WS-INT / 256
     PERFORM ADD-EDIT
     COMPUTE WS-EDIT = FUNCTION MOD(WS-INT, 256)
     PERFORM ADD-EDIT
     MOVE 4096 TO WS-AT
     PERFORM GET-INT
     IF WS-INT > 1577836800
         MOVE 1 TO WS-EDIT
     ELSE
         MOVE 0 TO WS-EDIT
     END-IF
     PERFORM ADD-EDIT
     MOVE "0 12288 2 1 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test region chunk payload at sector 2: Int length = data + 1, compression byte 2, then "
         & "the zlib stream of the bytes written" TO TL-CASE
     MOVE 8192 TO WS-AT
     PERFORM GET-INT
     COMPUTE WS-IN-LENGTH = WS-INT - 1
     CALL STATIC "cc_inflate" USING BY VALUE WS-MODE BY REFERENCE WS-FILE(8198:1)
         BY VALUE WS-IN-LENGTH BY REFERENCE WS-INFLATED BY VALUE WS-INFLATED-CAPACITY
         BY REFERENCE WS-INFLATED-LENGTH RETURNING WS-RC
     MOVE SPACES TO WS-TEXT
     COMPUTE WS-EDIT = FUNCTION ORD(WS-FILE(8197:1)) - 1
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE WS-RC TO WS-EDIT
     PERFORM ADD-EDIT
     MOVE WS-INFLATED-LENGTH TO WS-EDIT
     PERFORM ADD-EDIT
     IF WS-INFLATED(1:300) = WS-A
         STRING FUNCTION TRIM(WS-TEXT) " same" DELIMITED BY SIZE INTO WS-TEXT
     END-IF
     MOVE "2 0 300 same" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test region read of chunk (0, 0) gives the bytes written, PB-POS 0" TO TL-CASE
     PERFORM READ-CHUNK
     MOVE "0 300 0 same" TO TL-EXPECTED
     PERFORM DESCRIBE-READ
     IF RB-LENGTH = 300
         PERFORM COMPARE-A
     END-IF
     PERFORM CHECK

     MOVE "test region read of an absent chunk of an existing file, and of a chunk whose region "
         & "file does not exist: outcome 1 (absent), empty buffer" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     PERFORM READ-CHUNK
     MOVE WS-OUTCOME TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE RB-LENGTH TO WS-EDIT
     PERFORM ADD-EDIT
     MOVE 40 TO WS-CX
     PERFORM READ-CHUNK
     MOVE WS-OUTCOME TO WS-EDIT
     PERFORM ADD-EDIT
     MOVE RB-LENGTH TO WS-EDIT
     PERFORM ADD-EDIT
     MOVE "1 0 1 0" TO TL-EXPECTED
     PERFORM CHECK

*>   Negative chunk coordinates: region (-1, -2), table index 31 + 31 * 32 = 1023.
     MOVE "test region chunk (-1, -33) goes to r.-1.-2.mca at location entry 1023 and reads back"
         TO TL-CASE
     MOVE -1 TO WS-CX
     MOVE -33 TO WS-CZ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-A WS-A-LENGTH
     CALL "REGION-WRITE" USING WS-DIR WS-DIR-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     MOVE "build/core-test-region/r.-1.-2.mca" TO WS-FILE-NAME
     PERFORM READ-FILE
     MOVE SPACES TO WS-TEXT
     MOVE WS-FILE-SIZE TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE 4092 TO WS-AT
     PERFORM GET-INT
     MOVE WS-INT TO WS-EDIT
     PERFORM ADD-EDIT
     PERFORM READ-CHUNK
     MOVE WS-OUTCOME TO WS-EDIT
     PERFORM ADD-EDIT
     PERFORM COMPARE-A
     MOVE "12288 513 0 same" TO TL-EXPECTED
     PERFORM CHECK

*>   Growth: (1, 0) takes sector 3; (0, 0) rewritten with 9000 incompressible bytes needs 3
*>   sectors, so it moves to sector 4 (the end of the file) and the file grows to 7 sectors.
     MOVE "test region rewrite of a grown chunk moves it to the end of the file (offset 4 count 3, "
         & "28672 bytes); both chunks read back" TO TL-CASE
     MOVE 1 TO WS-CX
     MOVE 0 TO WS-CZ
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-B WS-B-LENGTH
     CALL "REGION-WRITE" USING WS-DIR WS-DIR-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     MOVE 0 TO WS-CX
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-C WS-C-LENGTH
     CALL "REGION-WRITE" USING WS-DIR WS-DIR-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     MOVE "build/core-test-region/r.0.0.mca" TO WS-FILE-NAME
     PERFORM READ-FILE
     MOVE SPACES TO WS-TEXT
     MOVE WS-FILE-SIZE TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE 0 TO WS-AT
     PERFORM GET-INT
     COMPUTE WS-EDIT = WS-INT / 256
     PERFORM ADD-EDIT
     COMPUTE WS-EDIT = FUNCTION MOD(WS-INT, 256)
     PERFORM ADD-EDIT
     MOVE 4 TO WS-AT
     PERFORM GET-INT
     COMPUTE WS-EDIT = WS-INT / 256
     PERFORM ADD-EDIT
     PERFORM READ-CHUNK
     IF WS-OUTCOME = 0 AND RB-LENGTH = 9000
         CALL "PB-GET-BYTES" USING RB-BUFFER WS-INFLATED RB-LENGTH
         IF WS-INFLATED(1:9000) = WS-C
             STRING FUNCTION TRIM(WS-TEXT) " grown-same" DELIMITED BY SIZE INTO WS-TEXT
         END-IF
     END-IF
     MOVE 1 TO WS-CX
     PERFORM READ-CHUNK
     IF WS-OUTCOME = 0 AND RB-LENGTH = 40
         CALL "PB-GET-BYTES" USING RB-BUFFER WS-INFLATED RB-LENGTH
         IF WS-INFLATED(1:40) = WS-B
             STRING FUNCTION TRIM(WS-TEXT) " small-same" DELIMITED BY SIZE INTO WS-TEXT
         END-IF
     END-IF
     MOVE "28672 4 3 3 grown-same small-same" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test region rewrite of a chunk that still fits its sectors stays in place (offset 4 "
         & "count 1) and reads back" TO TL-CASE
     MOVE 0 TO WS-CX
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-APPEND-BYTES" USING PB-BUFFER WS-A WS-A-LENGTH
     CALL "REGION-WRITE" USING WS-DIR WS-DIR-LENGTH WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     PERFORM READ-FILE
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-AT
     PERFORM GET-INT
     COMPUTE WS-EDIT = WS-INT / 256
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     COMPUTE WS-EDIT = FUNCTION MOD(WS-INT, 256)
     PERFORM ADD-EDIT
     PERFORM READ-CHUNK
     PERFORM COMPARE-A
     MOVE "4 1 same" TO TL-EXPECTED
     PERFORM CHECK

*>   Hand-made r.2.0.mca (chunks x 64 to 95, z 0 to 31), 5 sectors: entry 0 overlaps the header
*>   (offset 1), entry 1 points past the end (offset 9), entry 2 has count 0, entry 3 a payload of
*>   length 0 (sector 2), entry 4 a length longer than its sector (sector 3), entry 5 a payload
*>   that is not zlib (sector 4).
     MOVE "test region entries overlapping the header, past the end of the file or with count 0, "
         & "zero and truncated lengths and a payload that does not inflate all read as absent"
         TO TL-CASE
     MOVE LOW-VALUES TO WS-FILE
     MOVE 0 TO WS-AT
     MOVE 257 TO WS-INT
     PERFORM PUT-INT
     MOVE 4 TO WS-AT
     MOVE 2305 TO WS-INT
     PERFORM PUT-INT
     MOVE 8 TO WS-AT
     MOVE 512 TO WS-INT
     PERFORM PUT-INT
     MOVE 12 TO WS-AT
     MOVE 513 TO WS-INT
     PERFORM PUT-INT
     MOVE 16 TO WS-AT
     MOVE 769 TO WS-INT
     PERFORM PUT-INT
     MOVE 20 TO WS-AT
     MOVE 1025 TO WS-INT
     PERFORM PUT-INT
     MOVE 12288 TO WS-AT
     MOVE 5000 TO WS-INT
     PERFORM PUT-INT
     MOVE 16384 TO WS-AT
     MOVE 11 TO WS-INT
     PERFORM PUT-INT
     MOVE FUNCTION CHAR(3) TO WS-FILE(16389:1)
     MOVE "not zlib!!" TO WS-FILE(16390:10)
     MOVE "build/core-test-region/r.2.0.mca" TO WS-FILE-NAME
     MOVE 20480 TO WS-FILE-SIZE
     PERFORM WRITE-FILE
     MOVE SPACES TO WS-TEXT
     MOVE 0 TO WS-CZ
     PERFORM VARYING WS-N FROM 64 BY 1 UNTIL WS-N > 69
         MOVE WS-N TO WS-CX
         PERFORM READ-CHUNK
         MOVE WS-OUTCOME TO WS-EDIT
         PERFORM ADD-EDIT
     END-PERFORM
     MOVE "1 1 1 1 1 1" TO TL-EXPECTED
     PERFORM CHECK

     MOVE "test region a file shorter than its 8192-byte header reads as absent" TO TL-CASE
     MOVE "build/core-test-region/r.3.0.mca" TO WS-FILE-NAME
     MOVE 100 TO WS-FILE-SIZE
     MOVE ALL "x" TO WS-FILE(1:100)
     PERFORM WRITE-FILE
     MOVE 96 TO WS-CX
     PERFORM READ-CHUNK
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT

     MOVE "test region write into a folder that does not exist: outcome 1" TO TL-CASE
     MOVE "build/core-test-region/missing/x" TO WS-FILE-NAME
     MOVE 32 TO WS-N
     CALL "REGION-WRITE" USING WS-FILE-NAME WS-N WS-CX WS-CZ PB-BUFFER WS-OUTCOME
     MOVE WS-OUTCOME TO TL-OBSERVED-N
     MOVE 1 TO TL-EXPECTED-N
     MOVE "N" TO TL-MODE
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     STOP RUN.

 READ-CHUNK.
     CALL "PB-RESET" USING RB-BUFFER
     CALL "REGION-READ" USING WS-DIR WS-DIR-LENGTH WS-CX WS-CZ RB-BUFFER WS-OUTCOME.

 DESCRIBE-READ.
     MOVE SPACES TO WS-TEXT
     MOVE WS-OUTCOME TO WS-EDIT
     STRING FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT
     MOVE RB-LENGTH TO WS-EDIT
     PERFORM ADD-EDIT
     MOVE RB-POS TO WS-EDIT
     PERFORM ADD-EDIT.

 COMPARE-A.
     IF WS-OUTCOME = 0 AND RB-LENGTH = 300
         CALL "PB-GET-BYTES" USING RB-BUFFER WS-INFLATED RB-LENGTH
         IF WS-INFLATED(1:300) = WS-A
             STRING FUNCTION TRIM(WS-TEXT) " same" DELIMITED BY SIZE INTO WS-TEXT
         END-IF
     END-IF.

 READ-FILE.
     MOVE LOW-VALUES TO WS-FILE
     MOVE 0 TO WS-FILE-SIZE
     CALL "CBL_OPEN_FILE" USING WS-FILE-NAME WS-READ-ACCESS WS-DENY WS-DEVICE WS-HANDLE
     IF RETURN-CODE = 0
         MOVE 0 TO WS-OFFSET WS-COUNT
         MOVE 128 TO WS-FLAGS
         CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS WS-DUMMY
         MOVE WS-OFFSET TO WS-FILE-SIZE
         MOVE 0 TO WS-OFFSET WS-FLAGS
         MOVE FUNCTION MIN(WS-FILE-SIZE, 65536) TO WS-COUNT
         CALL "CBL_READ_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS WS-FILE
         CALL "CBL_CLOSE_FILE" USING WS-HANDLE
     END-IF
     MOVE 0 TO RETURN-CODE.

 WRITE-FILE.
     CALL "CBL_CREATE_FILE" USING WS-FILE-NAME WS-WRITE-ACCESS WS-DENY WS-DEVICE WS-HANDLE
     MOVE 0 TO WS-OFFSET WS-FLAGS
     MOVE WS-FILE-SIZE TO WS-COUNT
     CALL "CBL_WRITE_FILE" USING WS-HANDLE WS-OFFSET WS-COUNT WS-FLAGS WS-FILE
     CALL "CBL_CLOSE_FILE" USING WS-HANDLE
     MOVE 0 TO RETURN-CODE.

*> WS-INT = the unsigned big-endian Int at file offset WS-AT (0-based).
 GET-INT.
     MOVE 0 TO WS-INT
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         COMPUTE WS-INT = WS-INT * 256 + FUNCTION ORD(WS-FILE(WS-AT + WS-I:1)) - 1
     END-PERFORM.

*> The big-endian Int WS-INT (0 to 2^31 - 1) at file offset WS-AT.
 PUT-INT.
     MOVE WS-INT TO WS-Q
     PERFORM VARYING WS-I FROM 4 BY -1 UNTIL WS-I < 1
         COMPUTE WS-Q2 = WS-Q / 256
         COMPUTE WS-BYTE = WS-Q - WS-Q2 * 256
         MOVE WS-BYTE-X TO WS-FILE(WS-AT + WS-I:1)
         MOVE WS-Q2 TO WS-Q
     END-PERFORM.

 ADD-EDIT.
     STRING FUNCTION TRIM(WS-TEXT) " " FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT.

 CHECK.
     MOVE "T" TO TL-MODE
     MOVE FUNCTION TRIM(WS-TEXT) TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-REGION.
