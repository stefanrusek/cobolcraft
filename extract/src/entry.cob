*> One entry of the jar (22 §7.3 step 7, substeps 5 to 7). EX-ENTRY-READ USING zip handle, entry number (BINARY-LONG,
*> 1-based), area (PIC X, any size: the buffer), capacity (BINARY-LONG), length out (BINARY-LONG), CRC-32 out
*> (BINARY-LONG UNSIGNED, of the bytes read), status out (BINARY-LONG: 0, or the CCX number after its message: 20, 21,
*> 40, 41 or 42). The local header at the recorded offset must carry PK 03 04 and the central record's own name
*> (CCX-042); the entry is then inflated by ZIP-READ-RANGE and its CRC-32 compared with the central record (CCX-040).
*> Its own file: a caller in the same source file would be size-checked against the one-byte area.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-ENTRY-READ.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 COPY FMZIP.
 01 WS-NAME                PIC X(256).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-RANGE-STATUS        BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-HEADER              BINARY-LONG.
 01 WS-LOCAL-NAME-LENGTH   BINARY-LONG.
 01 WS-LOCAL-END           BINARY-LONG.
 01 WS-MATCH               BINARY-LONG.
 01 WS-HDR                 PIC X(30).
 01 WS-HDR-BYTES REDEFINES WS-HDR.
    05 WS-HB               BINARY-CHAR UNSIGNED OCCURS 30 TIMES.
 01 WS-CRC-BYTES           PIC X(4).
 01 WS-CRC-PARTS REDEFINES WS-CRC-BYTES.
    05 WS-CB               BINARY-CHAR UNSIGNED OCCURS 4 TIMES.
 01 WS-CENTRAL             BINARY-LONG UNSIGNED.
 01 WS-CENTRAL-D           BINARY-DOUBLE.
 01 WS-CRC                 BINARY-LONG UNSIGNED.
 01 WS-HEX-FOUND           PIC X(8).
 01 WS-HEX-EXPECTED        PIC X(8).
 01 WS-NUMBER              BINARY-DOUBLE.
 01 WS-NUMBER-TEXT         PIC X(20).
 01 B-DATA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-ZIP                  USAGE POINTER.
 01 L-INDEX                BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-CRC                  BINARY-LONG UNSIGNED.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-ZIP L-INDEX L-AREA L-CAPACITY L-LENGTH L-CRC L-STATUS.
     MOVE 0 TO L-STATUS L-LENGTH L-CRC
     MOVE L-INDEX TO WS-ENTRY
     SET ADDRESS OF ZIP-ARCHIVE TO L-ZIP
     SET ADDRESS OF ZIP-TABLE TO ZA-TABLE-ADDR
     SET ADDRESS OF B-DATA TO ZA-DATA-ADDR
     CALL "ZIP-NAME" USING L-ZIP WS-ENTRY WS-NAME WS-NAME-LENGTH
     MOVE SPACES TO EXM-ARG(1) EXM-ARG(2) EXM-ARG(3)
     MOVE WS-NAME(1:WS-NAME-LENGTH) TO EXM-ARG(1)
*>   The local header: its signature and its own name must be the central record's (an unusable record is left to
*>   ZIP-READ-RANGE to classify).
     IF ZE-USABLE(WS-ENTRY) = 1
         MOVE B-DATA(ZE-LOCAL(WS-ENTRY) + 1:30) TO WS-HDR
         COMPUTE WS-LOCAL-NAME-LENGTH = WS-HB(27) + WS-HB(28) * 256
         COMPUTE WS-LOCAL-END = ZE-LOCAL(WS-ENTRY) + 30 + WS-LOCAL-NAME-LENGTH
         MOVE 0 TO WS-MATCH
         IF WS-HDR(1:4) = X"504B0304" AND WS-LOCAL-NAME-LENGTH = WS-NAME-LENGTH AND WS-LOCAL-END <= ZA-DATA-SIZE
             COMPUTE WS-HEADER = ZE-LOCAL(WS-ENTRY) + 31
             IF B-DATA(WS-HEADER:WS-NAME-LENGTH) = WS-NAME(1:WS-NAME-LENGTH)
                 MOVE 1 TO WS-MATCH
             END-IF
         END-IF
         IF WS-MATCH = 0
             MOVE 42 TO WS-CODE L-STATUS
             CALL "EX-SAY" USING WS-CODE
             GOBACK
         END-IF
     END-IF
     CALL "ZIP-READ-RANGE" USING L-ZIP WS-ENTRY L-AREA L-CAPACITY L-LENGTH WS-RANGE-STATUS
     EVALUATE WS-RANGE-STATUS
         WHEN FM-ZIP-OK
             CONTINUE
         WHEN FM-ZIP-CAPACITY
             MOVE "larger than the 1048576-byte buffer" TO EXM-ARG(2)
             MOVE 41 TO WS-CODE
         WHEN FM-ZIP-ENCRYPTED
             MOVE EXC-PATH TO EXM-ARG(1)
             STRING "encrypted entry " WS-NAME(1:WS-NAME-LENGTH) DELIMITED BY SIZE INTO EXM-ARG(2)
             MOVE 21 TO WS-CODE
         WHEN FM-ZIP-METHOD
             MOVE EXC-PATH TO EXM-ARG(1)
             MOVE ZE-METHOD(WS-ENTRY) TO WS-NUMBER
             CALL "EX-NUM" USING WS-NUMBER WS-NUMBER-TEXT
             STRING "compression method " FUNCTION TRIM(WS-NUMBER-TEXT) " in entry " WS-NAME(1:WS-NAME-LENGTH)
                 DELIMITED BY SIZE INTO EXM-ARG(2)
             MOVE 21 TO WS-CODE
         WHEN FM-ZIP-ZIP64
             MOVE EXC-PATH TO EXM-ARG(1)
             MOVE "zip64" TO EXM-ARG(2)
             MOVE 21 TO WS-CODE
         WHEN OTHER
             MOVE "bad deflate data or a size that differs from the central record" TO EXM-ARG(2)
             MOVE 41 TO WS-CODE
             IF ZE-USABLE(WS-ENTRY) = 0
                 MOVE EXC-PATH TO EXM-ARG(1)
                 COMPUTE WS-NUMBER = WS-ENTRY - 1
                 CALL "EX-NUM" USING WS-NUMBER WS-NUMBER-TEXT
                 MOVE SPACES TO EXM-ARG(2)
                 STRING "bad central record at entry " FUNCTION TRIM(WS-NUMBER-TEXT) DELIMITED BY SIZE
                     INTO EXM-ARG(2)
                 MOVE 20 TO WS-CODE
             END-IF
     END-EVALUATE
     IF WS-RANGE-STATUS NOT = FM-ZIP-OK
         MOVE 0 TO L-LENGTH
         MOVE WS-CODE TO L-STATUS
         CALL "EX-SAY" USING WS-CODE
         GOBACK
     END-IF
*>   The CRC-32 of what was read against the central record's.
     MOVE 0 TO WS-CRC
     CALL "CRC32" USING L-AREA L-LENGTH WS-CRC
     MOVE WS-CRC TO L-CRC
     COMPUTE WS-HEADER = ZE-NAME-OFFSET(WS-ENTRY) - 46 + 16
     MOVE B-DATA(WS-HEADER:4) TO WS-CRC-BYTES
     COMPUTE WS-CENTRAL-D = WS-CB(1) + WS-CB(2) * 256 + WS-CB(3) * 65536 + WS-CB(4) * 16777216
     MOVE WS-CENTRAL-D TO WS-CENTRAL
     IF WS-CRC NOT = WS-CENTRAL
         CALL "EX-HEX8" USING WS-CRC WS-HEX-FOUND
         CALL "EX-HEX8" USING WS-CENTRAL WS-HEX-EXPECTED
         MOVE WS-HEX-FOUND TO EXM-ARG(2)
         MOVE WS-HEX-EXPECTED TO EXM-ARG(3)
         MOVE 40 TO WS-CODE L-STATUS
         CALL "EX-SAY" USING WS-CODE
     END-IF
     GOBACK.
 END PROGRAM EX-ENTRY-READ.
