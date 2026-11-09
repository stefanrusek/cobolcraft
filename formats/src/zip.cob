*> Zip archive reading (docs/protocol/08-resource-packs.md §1.1: a pack may be a zip archive; server
*> packs always are). ZIP-OPEN reads the whole file into allocated memory with the GnuCOBOL CBL_*
*> byte-stream routines (research R2), finds the end of central directory record by searching
*> backwards from the end of the file (past an archive comment of up to 65535 bytes) and lists the
*> central directory into an allocated entry table (client/copy/CLZIP.cpy). Entries are read from
*> their local header: method 0 (stored) is copied, method 8 (deflated) is inflated with cc_inflate
*> mode CC_RAW (contracts/shim-abi.md §5). Multi-disk and zip64 archives are not readable archives;
*> encrypted entries, other methods and zip64 entries read as corrupt. Entry names longer than 256
*> bytes (and empty names) are left out of the table. All numbers in the file are little-endian.

*> The name index (ZIP-OPEN builds it, ZIP-FIND asks it). ZIP-INDEX-PROBE hashes a name (h = h * 33 + byte
*> modulo 2147483647 over its bytes) to a slot of the table, then steps to the next slot (wrapping)
*> while a slot holds another entry's name; it stops at the slot of the entry with this name or at the
*> first empty slot. The table has 2 * count + 1 slots, so an empty slot always exists.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZIP-INDEX-PROBE.
*> USING handle (an archive whose table and index are allocated), name (PIC X(256)), name length
*> (1 to 256), slot out (the slot where the search stopped), entry out (the number of the entry with
*> this name, 0 when the slot is empty).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FMZIP.
 01 ZIP-INDEX              BASED.
    05 ZX-SLOT             BINARY-LONG OCCURS 131071 TIMES.
 01 WS-INDEX-ADDR          USAGE POINTER.
 01 WS-INDEX-BYTES         BINARY-LONG.
 01 WS-SLOTS               BINARY-LONG.
 01 WS-HASH                BINARY-DOUBLE.
 01 WS-STEP                BINARY-DOUBLE.
 01 WS-QUOTIENT            BINARY-DOUBLE.
 01 WS-K                   BINARY-LONG.
 01 WS-CANDIDATE           BINARY-LONG.
 01 WS-OFF                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-DONE                BINARY-LONG.
 01 B-DATA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-HANDLE               USAGE POINTER.
 01 L-NAME                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-SLOT                 BINARY-LONG.
 01 L-ENTRY                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-NAME L-LENGTH L-SLOT L-ENTRY.
     SET ADDRESS OF ZIP-ARCHIVE TO L-HANDLE
     SET ADDRESS OF ZIP-TABLE TO ZA-TABLE-ADDR
     COMPUTE WS-INDEX-BYTES = ZA-COUNT * 32
     COMPUTE WS-SLOTS = ZA-COUNT * 2 + 1
     SET WS-INDEX-ADDR TO ZA-TABLE-ADDR
     SET WS-INDEX-ADDR UP BY WS-INDEX-BYTES
     SET ADDRESS OF ZIP-INDEX TO WS-INDEX-ADDR
     SET ADDRESS OF B-DATA TO ZA-DATA-ADDR
     MOVE 5381 TO WS-HASH
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > L-LENGTH
         COMPUTE WS-STEP = WS-HASH * 33 + FUNCTION ORD(L-NAME(WS-K:1))
         DIVIDE WS-STEP BY 2147483647 GIVING WS-QUOTIENT REMAINDER WS-HASH
     END-PERFORM
     DIVIDE WS-HASH BY WS-SLOTS GIVING WS-QUOTIENT REMAINDER WS-STEP
     COMPUTE L-SLOT = WS-STEP + 1
     MOVE 0 TO L-ENTRY WS-DONE
     PERFORM UNTIL WS-DONE = 1
         MOVE ZX-SLOT(L-SLOT) TO WS-CANDIDATE
         IF WS-CANDIDATE = 0
             MOVE 1 TO WS-DONE
         ELSE
             MOVE ZE-NAME-OFFSET(WS-CANDIDATE) TO WS-OFF
             MOVE ZE-NAME-LENGTH(WS-CANDIDATE) TO WS-LEN
             IF WS-LEN = L-LENGTH AND B-DATA(WS-OFF:WS-LEN) = L-NAME(1:WS-LEN)
                 MOVE WS-CANDIDATE TO L-ENTRY
                 MOVE 1 TO WS-DONE
             ELSE
                 COMPUTE L-SLOT = FUNCTION MOD(L-SLOT, WS-SLOTS) + 1
             END-IF
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM ZIP-INDEX-PROBE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZIP-OPEN.
*> USING path (PIC X(1024)), path length, handle out (USAGE POINTER: an allocated archive, NULL on
*> failure), status out (BINARY-LONG: 0 ok, 1 the file cannot be opened or read, 2 not a readable
*> zip archive). Files larger than 1 GiB are not readable archives.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FMZIP.
 COPY FORMATS.
 01 ZIP-INDEX              BASED.
    05 ZX-SLOT             BINARY-LONG OCCURS 131071 TIMES.
 01 WS-NAME                PIC X(1024).
 01 WS-ACCESS              PIC X COMP-X VALUE 1.
 01 WS-DENY                PIC X COMP-X VALUE 0.
 01 WS-DEVICE              PIC X COMP-X VALUE 0.
 01 WS-FILE                PIC X(4).
 01 WS-OFFSET              PIC X(8) COMP-X.
 01 WS-COUNT               PIC X(4) COMP-X.
 01 WS-FLAGS               BINARY-CHAR UNSIGNED.
 01 WS-DUMMY               PIC X.
 01 WS-RC                  BINARY-LONG.
 01 WS-FILE-SIZE           BINARY-DOUBLE.
 01 WS-DATA-SIZE           BINARY-LONG.
 01 WS-DATA-ADDR           USAGE POINTER.
 01 WS-TABLE-ADDR          USAGE POINTER.
 01 WS-BYTES               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-EOCD                BINARY-LONG.
 01 WS-LOW                 BINARY-LONG.
 01 WS-P                   BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-DISK                BINARY-LONG.
 01 WS-CD-DISK             BINARY-LONG.
 01 WS-DISK-ENTRIES        BINARY-LONG.
 01 WS-TOTAL               BINARY-LONG.
 01 WS-CD-SIZE             BINARY-DOUBLE.
 01 WS-CD-OFFSET           BINARY-DOUBLE.
 01 WS-CD-END              BINARY-DOUBLE.
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-EXTRA-LENGTH        BINARY-LONG.
 01 WS-COMMENT-LENGTH      BINARY-LONG.
 01 WS-COMP                BINARY-DOUBLE.
 01 WS-SIZE                BINARY-DOUBLE.
 01 WS-LOCAL               BINARY-DOUBLE.
 01 WS-SLOT                BINARY-LONG.
 01 WS-INDEX-ADDR          USAGE POINTER.
 01 WS-ENTRY               BINARY-LONG.
 01 WS-ENTRY-NAME          PIC X(256).
 01 WS-OFF                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-REASON              BINARY-LONG.
 01 WS-MAX                 BINARY-DOUBLE VALUE 4294967295.
 01 WS-SIG-LOCATOR         PIC X(4) VALUE X"504B0607".
 01 WS-SIG-END             PIC X(4) VALUE X"504B0506".
 01 WS-SIG-CENTRAL         PIC X(4) VALUE X"504B0102".
 01 WS-HDR                 PIC X(46).
 01 WS-HDR-BYTES REDEFINES WS-HDR.
    05 WS-HB               BINARY-CHAR UNSIGNED OCCURS 46 TIMES.
 01 B-DATA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-PATH                 PIC X(1024).
 01 L-PATH-LENGTH          BINARY-LONG.
 01 L-HANDLE               USAGE POINTER.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-PATH L-PATH-LENGTH L-HANDLE L-STATUS.
     SET L-HANDLE TO NULL
     MOVE 1 TO L-STATUS
     MOVE SPACES TO WS-NAME
     IF L-PATH-LENGTH >= 1 AND L-PATH-LENGTH <= 1024
         MOVE L-PATH(1:L-PATH-LENGTH) TO WS-NAME
     END-IF
     CALL "CBL_OPEN_FILE" USING WS-NAME WS-ACCESS WS-DENY WS-DEVICE WS-FILE RETURNING WS-RC
     IF WS-RC NOT = 0
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF
     MOVE 0 TO WS-OFFSET WS-COUNT
     MOVE 128 TO WS-FLAGS
     CALL "CBL_READ_FILE" USING WS-FILE WS-OFFSET WS-COUNT WS-FLAGS WS-DUMMY
     MOVE WS-OFFSET TO WS-FILE-SIZE
     MOVE 2 TO L-STATUS
     IF WS-FILE-SIZE < 22 OR WS-FILE-SIZE > 1073741824
         CALL "CBL_CLOSE_FILE" USING WS-FILE
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF
     MOVE WS-FILE-SIZE TO WS-DATA-SIZE
     ALLOCATE WS-DATA-SIZE CHARACTERS RETURNING WS-DATA-ADDR
     SET ADDRESS OF B-DATA TO WS-DATA-ADDR
     MOVE 0 TO WS-OFFSET WS-FLAGS
     MOVE WS-DATA-SIZE TO WS-COUNT
     CALL "CBL_READ_FILE" USING WS-FILE WS-OFFSET WS-COUNT WS-FLAGS B-DATA RETURNING WS-RC
     CALL "CBL_CLOSE_FILE" USING WS-FILE
     IF WS-RC NOT = 0
         FREE WS-DATA-ADDR
         MOVE 1 TO L-STATUS
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF

*>   The end of central directory record: the last signature within 65535 + 22 bytes of the end.
     MOVE 0 TO WS-BAD
     MOVE FM-ZIP-CORRUPT TO WS-REASON
     MOVE -1 TO WS-EOCD
     COMPUTE WS-LOW = FUNCTION MAX(0, WS-DATA-SIZE - 22 - 65535)
     COMPUTE WS-P = WS-DATA-SIZE - 22
     PERFORM UNTIL WS-P < WS-LOW OR WS-EOCD >= 0
         IF B-DATA(WS-P + 1:4) = WS-SIG-END
             MOVE WS-P TO WS-EOCD
         END-IF
         SUBTRACT 1 FROM WS-P
     END-PERFORM
     IF WS-EOCD < 0
         MOVE 1 TO WS-BAD
     END-IF
     IF WS-BAD = 0
         MOVE B-DATA(WS-EOCD + 1:22) TO WS-HDR(1:22)
         COMPUTE WS-DISK = WS-HB(5) + WS-HB(6) * 256
         COMPUTE WS-CD-DISK = WS-HB(7) + WS-HB(8) * 256
         COMPUTE WS-DISK-ENTRIES = WS-HB(9) + WS-HB(10) * 256
         COMPUTE WS-TOTAL = WS-HB(11) + WS-HB(12) * 256
         COMPUTE WS-CD-SIZE = WS-HB(13) + WS-HB(14) * 256 + WS-HB(15) * 65536 + WS-HB(16) * 16777216
         COMPUTE WS-CD-OFFSET = WS-HB(17) + WS-HB(18) * 256 + WS-HB(19) * 65536 + WS-HB(20) * 16777216
         COMPUTE WS-CD-END = WS-CD-OFFSET + WS-CD-SIZE
*>       Zip64 (a maximum field or a locator before the end record) and several disks are refused
*>       with their own reason (22 §8.4); every other fault of the end record is a corrupt archive.
         EVALUATE TRUE
             WHEN WS-TOTAL = 65535 OR WS-DISK-ENTRIES = 65535 OR WS-CD-SIZE = WS-MAX OR WS-CD-OFFSET = WS-MAX
                     OR (WS-EOCD >= 20 AND B-DATA(WS-EOCD - 19:4) = WS-SIG-LOCATOR)
                 MOVE 1 TO WS-BAD
                 MOVE FM-ZIP-ZIP64 TO WS-REASON
             WHEN WS-DISK NOT = 0 OR WS-CD-DISK NOT = 0
                 MOVE 1 TO WS-BAD
                 MOVE FM-ZIP-MULTI-DISK TO WS-REASON
             WHEN WS-DISK-ENTRIES NOT = WS-TOTAL OR WS-CD-END > WS-EOCD
                 MOVE 1 TO WS-BAD
         END-EVALUATE
     END-IF

*>   The central directory into the entry table.
     SET WS-TABLE-ADDR TO NULL
     MOVE 0 TO WS-N
     IF WS-BAD = 0
*>       Room for the entries (32 bytes each) and, after the entries that are kept, the name index
*>       (2 slots of 4 bytes per entry and one more): the whole block starts zeroed.
         COMPUTE WS-BYTES = FUNCTION MAX(WS-TOTAL, 1) * 40 + 4
         ALLOCATE WS-BYTES CHARACTERS INITIALIZED RETURNING WS-TABLE-ADDR
         SET ADDRESS OF ZIP-TABLE TO WS-TABLE-ADDR
         MOVE WS-CD-OFFSET TO WS-P
         PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-TOTAL OR WS-BAD = 1
             MOVE 0 TO WS-NAME-LENGTH WS-EXTRA-LENGTH WS-COMMENT-LENGTH
             IF WS-P + 46 > WS-CD-END
                 MOVE 1 TO WS-BAD
             END-IF
             IF WS-BAD = 0
                 MOVE B-DATA(WS-P + 1:46) TO WS-HDR
                 COMPUTE WS-NAME-LENGTH = WS-HB(29) + WS-HB(30) * 256
                 COMPUTE WS-EXTRA-LENGTH = WS-HB(31) + WS-HB(32) * 256
                 COMPUTE WS-COMMENT-LENGTH = WS-HB(33) + WS-HB(34) * 256
                 IF WS-HDR(1:4) NOT = WS-SIG-CENTRAL
                         OR WS-P + 46 + WS-NAME-LENGTH + WS-EXTRA-LENGTH + WS-COMMENT-LENGTH > WS-CD-END
                     MOVE 1 TO WS-BAD
                 END-IF
             END-IF
             IF WS-BAD = 0 AND WS-NAME-LENGTH >= 1 AND WS-NAME-LENGTH <= 256
                 ADD 1 TO WS-N
                 COMPUTE ZE-NAME-OFFSET(WS-N) = WS-P + 47
                 MOVE WS-NAME-LENGTH TO ZE-NAME-LENGTH(WS-N)
                 COMPUTE ZE-FLAGS(WS-N) = WS-HB(9) + WS-HB(10) * 256
                 COMPUTE ZE-METHOD(WS-N) = WS-HB(11) + WS-HB(12) * 256
                 COMPUTE WS-COMP = WS-HB(21) + WS-HB(22) * 256 + WS-HB(23) * 65536 + WS-HB(24) * 16777216
                 COMPUTE WS-SIZE = WS-HB(25) + WS-HB(26) * 256 + WS-HB(27) * 65536 + WS-HB(28) * 16777216
                 COMPUTE WS-LOCAL = WS-HB(43) + WS-HB(44) * 256 + WS-HB(45) * 65536 + WS-HB(46) * 16777216
                 MOVE 1 TO ZE-USABLE(WS-N)
                 IF WS-COMP > WS-DATA-SIZE OR WS-SIZE > 2147483647 OR WS-LOCAL >= WS-DATA-SIZE
                     MOVE 0 TO ZE-USABLE(WS-N) WS-COMP WS-SIZE WS-LOCAL
                 END-IF
                 MOVE WS-COMP TO ZE-COMP-SIZE(WS-N)
                 MOVE WS-SIZE TO ZE-SIZE(WS-N)
                 MOVE WS-LOCAL TO ZE-LOCAL(WS-N)
             END-IF
             COMPUTE WS-P = WS-P + 46 + WS-NAME-LENGTH + WS-EXTRA-LENGTH + WS-COMMENT-LENGTH
         END-PERFORM
     END-IF
     IF WS-BAD = 1
         FREE WS-DATA-ADDR
         IF WS-TABLE-ADDR NOT = NULL
             FREE WS-TABLE-ADDR
         END-IF
         MOVE WS-REASON TO L-STATUS
         MOVE 0 TO RETURN-CODE
         GOBACK
     END-IF
     ALLOCATE ZIP-ARCHIVE
     SET ZA-DATA-ADDR TO WS-DATA-ADDR
     SET ZA-TABLE-ADDR TO WS-TABLE-ADDR
     MOVE WS-DATA-SIZE TO ZA-DATA-SIZE
     MOVE WS-N TO ZA-COUNT
     SET L-HANDLE TO ADDRESS OF ZIP-ARCHIVE
*>   The name index: every entry in order, the first of equal names keeps the slot.
     COMPUTE WS-BYTES = WS-N * 32
     SET WS-INDEX-ADDR TO WS-TABLE-ADDR
     SET WS-INDEX-ADDR UP BY WS-BYTES
     SET ADDRESS OF ZIP-INDEX TO WS-INDEX-ADDR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-N
         MOVE ZE-NAME-OFFSET(WS-I) TO WS-OFF
         MOVE ZE-NAME-LENGTH(WS-I) TO WS-LEN
         MOVE B-DATA(WS-OFF:WS-LEN) TO WS-ENTRY-NAME
         CALL "ZIP-INDEX-PROBE" USING L-HANDLE WS-ENTRY-NAME WS-LEN WS-SLOT WS-ENTRY
         IF WS-ENTRY = 0
             MOVE WS-I TO ZX-SLOT(WS-SLOT)
         END-IF
     END-PERFORM
     MOVE 0 TO L-STATUS
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM ZIP-OPEN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZIP-CLOSE.
*> USING handle (USAGE POINTER): frees the archive and sets the handle NULL; NULL is a no-op.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FMZIP.
 LINKAGE SECTION.
 01 L-HANDLE               USAGE POINTER.
 PROCEDURE DIVISION USING L-HANDLE.
     IF L-HANDLE NOT = NULL
         SET ADDRESS OF ZIP-ARCHIVE TO L-HANDLE
         FREE ZA-DATA-ADDR
         FREE ZA-TABLE-ADDR
         FREE L-HANDLE
     END-IF
     SET L-HANDLE TO NULL
     GOBACK.
 END PROGRAM ZIP-CLOSE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZIP-COUNT.
*> USING handle, count out (BINARY-LONG): the number of entries in the table.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FMZIP.
 LINKAGE SECTION.
 01 L-HANDLE               USAGE POINTER.
 01 L-COUNT                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-COUNT.
     SET ADDRESS OF ZIP-ARCHIVE TO L-HANDLE
     MOVE ZA-COUNT TO L-COUNT
     GOBACK.
 END PROGRAM ZIP-COUNT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZIP-NAME.
*> USING handle, index (1-based BINARY-LONG), name out (PIC X(256), space padded), name length out
*> (0 and spaces for an index out of range). Directory entries keep their trailing "/".
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FMZIP.
 01 WS-OFF                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 B-DATA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-HANDLE               USAGE POINTER.
 01 L-INDEX                BINARY-LONG.
 01 L-NAME                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-INDEX L-NAME L-LENGTH.
     MOVE SPACES TO L-NAME
     MOVE 0 TO L-LENGTH
     SET ADDRESS OF ZIP-ARCHIVE TO L-HANDLE
     IF L-INDEX >= 1 AND L-INDEX <= ZA-COUNT
         SET ADDRESS OF ZIP-TABLE TO ZA-TABLE-ADDR
         SET ADDRESS OF B-DATA TO ZA-DATA-ADDR
         MOVE ZE-NAME-OFFSET(L-INDEX) TO WS-OFF
         MOVE ZE-NAME-LENGTH(L-INDEX) TO WS-LEN
         MOVE B-DATA(WS-OFF:WS-LEN) TO L-NAME
         MOVE WS-LEN TO L-LENGTH
     END-IF
     GOBACK.
 END PROGRAM ZIP-NAME.

 IDENTIFICATION DIVISION.
PROGRAM-ID. ZIP-FIND.
*> USING handle, name (PIC X(256)), name length, index out (BINARY-LONG: the first entry with
*> exactly that name, 0 = absent; a length outside 1 to 256 is absent). The name index answers it:
*> the time does not grow with the number of entries.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-LEN                 BINARY-LONG.
 01 WS-SLOT                BINARY-LONG.
 LINKAGE SECTION.
 01 L-HANDLE               USAGE POINTER.
 01 L-NAME                 PIC X(256).
 01 L-LENGTH               BINARY-LONG.
 01 L-INDEX                BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-NAME L-LENGTH L-INDEX.
     MOVE 0 TO L-INDEX
     MOVE L-LENGTH TO WS-LEN
     IF WS-LEN >= 1 AND WS-LEN <= 256
         CALL "ZIP-INDEX-PROBE" USING L-HANDLE L-NAME WS-LEN WS-SLOT L-INDEX
     END-IF
     GOBACK.
 END PROGRAM ZIP-FIND.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZIP-SIZE.
*> USING handle, index (1-based), uncompressed size out (BINARY-LONG; 0 for an index out of range
*> and for an entry whose sizes cannot be used, such as a zip64 entry).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FMZIP.
 LINKAGE SECTION.
 01 L-HANDLE               USAGE POINTER.
 01 L-INDEX                BINARY-LONG.
 01 L-SIZE                 BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-INDEX L-SIZE.
     MOVE 0 TO L-SIZE
     SET ADDRESS OF ZIP-ARCHIVE TO L-HANDLE
     IF L-INDEX >= 1 AND L-INDEX <= ZA-COUNT
         SET ADDRESS OF ZIP-TABLE TO ZA-TABLE-ADDR
         MOVE ZE-SIZE(L-INDEX) TO L-SIZE
     END-IF
     GOBACK.
 END PROGRAM ZIP-SIZE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZIP-READ-RANGE.
*> USING handle, index (1-based), area (any size), capacity (BINARY-LONG), length out (BINARY-LONG),
*> status out (BINARY-LONG): inflates (method 8) or copies (method 0) one entry into the caller's
*> buffer, the extraction tool's per-entry call (22 §7.3 step 7), and says why it cannot (22 §8.4):
*> FM-ZIP-OK (length = the bytes read); FM-ZIP-NO-ENTRY (an index out of range); FM-ZIP-ZIP64 (a zip64
*> marker in the entry); FM-ZIP-CORRUPT (an unusable entry, a bad local header, data past the end of
*> the file, an inflate failure or a size mismatch); FM-ZIP-ENCRYPTED (flag bit 0);
*> FM-ZIP-METHOD (a method other than 0 and 8); FM-ZIP-CAPACITY (the size exceeds the capacity: length =
*> the size, nothing written). Length is 0 for every other status. The CRC-32 is not checked here.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CCSHIM.
 COPY FMZIP.
 COPY FORMATS.
 01 WS-I                   BINARY-LONG.
 01 WS-METHOD              BINARY-LONG.
 01 WS-COMP                BINARY-LONG.
 01 WS-SIZE                BINARY-LONG.
 01 WS-LOCAL               BINARY-LONG.
 01 WS-START               BINARY-LONG.
 01 WS-MODE                BINARY-LONG VALUE CC-RAW.
 01 WS-IN-ADDR             USAGE POINTER.
 01 WS-OUT-ADDR            USAGE POINTER.
 01 WS-OUT-LENGTH          BINARY-LONG.
 01 WS-RC                  BINARY-LONG.
 01 WS-SIG-LOCAL           PIC X(4) VALUE X"504B0304".
 01 WS-ZIP64               BINARY-LONG.
 01 WS-HEADER              BINARY-LONG.
 01 WS-FOUR-F              PIC X(4).
 01 WS-HDR                 PIC X(30).
 01 WS-HDR-BYTES REDEFINES WS-HDR.
    05 WS-HB               BINARY-CHAR UNSIGNED OCCURS 30 TIMES.
 01 B-DATA                 PIC X(1073741824) BASED.
 01 B-AREA                 PIC X(1073741824) BASED.
 LINKAGE SECTION.
 01 L-HANDLE               USAGE POINTER.
 01 L-INDEX                BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-INDEX L-AREA L-CAPACITY L-LENGTH L-STATUS.
     MOVE 0 TO L-LENGTH
     MOVE FM-ZIP-NO-ENTRY TO L-STATUS
     MOVE L-INDEX TO WS-I
     SET ADDRESS OF ZIP-ARCHIVE TO L-HANDLE
     IF WS-I < 1 OR WS-I > ZA-COUNT
         GOBACK
     END-IF
     SET ADDRESS OF ZIP-TABLE TO ZA-TABLE-ADDR
     SET ADDRESS OF B-DATA TO ZA-DATA-ADDR
     MOVE ZE-METHOD(WS-I) TO WS-METHOD
     MOVE ZE-COMP-SIZE(WS-I) TO WS-COMP
     MOVE ZE-SIZE(WS-I) TO WS-SIZE
     MOVE ZE-LOCAL(WS-I) TO WS-LOCAL
*>   An unusable entry is a zip64 one when a size or the offset in its central record is 0xFFFFFFFF
*>   (the central record is the 46 bytes before the name).
     MOVE 0 TO WS-ZIP64
     IF ZE-USABLE(WS-I) = 0
         COMPUTE WS-HEADER = ZE-NAME-OFFSET(WS-I) - 46
         MOVE ALL X"FF" TO WS-FOUR-F
         IF B-DATA(WS-HEADER + 20:4) = WS-FOUR-F OR B-DATA(WS-HEADER + 24:4) = WS-FOUR-F
                 OR B-DATA(WS-HEADER + 42:4) = WS-FOUR-F
             MOVE 1 TO WS-ZIP64
         END-IF
     END-IF
     EVALUATE TRUE
         WHEN WS-ZIP64 = 1
             MOVE FM-ZIP-ZIP64 TO L-STATUS
         WHEN ZE-USABLE(WS-I) = 0 OR WS-LOCAL + 30 > ZA-DATA-SIZE
             MOVE FM-ZIP-CORRUPT TO L-STATUS
         WHEN FUNCTION MOD(ZE-FLAGS(WS-I), 2) = 1
             MOVE FM-ZIP-ENCRYPTED TO L-STATUS
         WHEN WS-METHOD NOT = 0 AND WS-METHOD NOT = 8
             MOVE FM-ZIP-METHOD TO L-STATUS
         WHEN OTHER
             MOVE FM-ZIP-OK TO L-STATUS
     END-EVALUATE
     IF L-STATUS NOT = FM-ZIP-OK
         GOBACK
     END-IF
     MOVE FM-ZIP-CORRUPT TO L-STATUS
     MOVE B-DATA(WS-LOCAL + 1:30) TO WS-HDR
     COMPUTE WS-START = WS-LOCAL + 30 + WS-HB(27) + WS-HB(28) * 256 + WS-HB(29) + WS-HB(30) * 256
     IF WS-HDR(1:4) NOT = WS-SIG-LOCAL OR WS-START + WS-COMP > ZA-DATA-SIZE
             OR (WS-METHOD = 0 AND WS-COMP NOT = WS-SIZE)
         GOBACK
     END-IF
     IF WS-SIZE > L-CAPACITY
         MOVE FM-ZIP-CAPACITY TO L-STATUS
         MOVE WS-SIZE TO L-LENGTH
         GOBACK
     END-IF
     IF WS-SIZE > 0 AND WS-METHOD = 0
         SET ADDRESS OF B-AREA TO ADDRESS OF L-AREA
         MOVE B-DATA(WS-START + 1:WS-SIZE) TO B-AREA(1:WS-SIZE)
     END-IF
     IF WS-SIZE > 0 AND WS-METHOD = 8
         SET WS-IN-ADDR TO ZA-DATA-ADDR
         SET WS-IN-ADDR UP BY WS-START
         SET WS-OUT-ADDR TO ADDRESS OF L-AREA
         CALL STATIC "cc_inflate" USING BY VALUE WS-MODE BY VALUE WS-IN-ADDR BY VALUE WS-COMP
             BY VALUE WS-OUT-ADDR BY VALUE WS-SIZE BY REFERENCE WS-OUT-LENGTH RETURNING WS-RC
         IF WS-RC NOT = 0 OR WS-OUT-LENGTH NOT = WS-SIZE
             MOVE 0 TO RETURN-CODE
             GOBACK
         END-IF
     END-IF
     MOVE WS-SIZE TO L-LENGTH
     MOVE FM-ZIP-OK TO L-STATUS
     MOVE 0 TO RETURN-CODE
     GOBACK.
 END PROGRAM ZIP-READ-RANGE.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZIP-READ.
*> USING handle, index (1-based), area (any size), capacity (BINARY-LONG), length out (BINARY-LONG),
*> status out (BINARY-LONG: 0 ok, 2 corrupt or unsupported: index out of range, an unusable or
*> encrypted entry, a method other than 0 or 8, a bad local header, data past the end of the file,
*> an inflate failure or a size mismatch; 5 the uncompressed size exceeds the capacity). Length is
*> 0 unless the status is 0. The pack readers' call: ZIP-READ-RANGE with its reasons folded into 2.
 DATA DIVISION.
 LINKAGE SECTION.
 01 L-HANDLE               USAGE POINTER.
 01 L-INDEX                BINARY-LONG.
 01 L-AREA                 PIC X.
 01 L-CAPACITY             BINARY-LONG.
 01 L-LENGTH               BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-INDEX L-AREA L-CAPACITY L-LENGTH L-STATUS.
     CALL "ZIP-READ-RANGE" USING L-HANDLE L-INDEX L-AREA L-CAPACITY L-LENGTH L-STATUS
     IF L-STATUS = 5
         MOVE 0 TO L-LENGTH
     END-IF
     IF L-STATUS NOT = 0 AND L-STATUS NOT = 5
         MOVE 2 TO L-STATUS
     END-IF
     GOBACK.
 END PROGRAM ZIP-READ.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. ZIP-CRC-CHECK.
*> USING handle, index (1-based), status out (BINARY-LONG): reads the entry (as ZIP-READ-RANGE) and
*> compares the CRC-32 of its bytes with the one in the entry's central record (22 §7.3 step 7).
*> FM-ZIP-OK: equal; FM-ZIP-CRC: different; any other status is the reason ZIP-READ-RANGE gives
*> (FM-ZIP-NO-ENTRY, -ZIP64, -ENCRYPTED, -METHOD, -CORRUPT).
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY FMZIP.
 COPY FORMATS.
 01 WS-BYTES               BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-BUFFER-ADDR         USAGE POINTER.
 01 WS-CRC                 BINARY-LONG UNSIGNED.
 01 WS-CENTRAL             BINARY-DOUBLE.
 01 WS-HEADER              BINARY-LONG.
 01 WS-CRC-BYTES           PIC X(4).
 01 WS-CRC-PARTS REDEFINES WS-CRC-BYTES.
    05 WS-CB               BINARY-CHAR UNSIGNED OCCURS 4 TIMES.
 01 B-DATA                 PIC X(1073741824) BASED.
 01 B-BUFFER               PIC X BASED.
 LINKAGE SECTION.
 01 L-HANDLE               USAGE POINTER.
 01 L-INDEX                BINARY-LONG.
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-HANDLE L-INDEX L-STATUS.
     MOVE FM-ZIP-NO-ENTRY TO L-STATUS
     SET ADDRESS OF ZIP-ARCHIVE TO L-HANDLE
     IF L-INDEX >= 1 AND L-INDEX <= ZA-COUNT
         SET ADDRESS OF ZIP-TABLE TO ZA-TABLE-ADDR
         SET ADDRESS OF B-DATA TO ZA-DATA-ADDR
         MOVE ZE-SIZE(L-INDEX) TO WS-BYTES
         COMPUTE WS-BYTES = FUNCTION MAX(WS-BYTES, 1)
         ALLOCATE WS-BYTES CHARACTERS RETURNING WS-BUFFER-ADDR
         SET ADDRESS OF B-BUFFER TO WS-BUFFER-ADDR
         MOVE ZE-SIZE(L-INDEX) TO WS-BYTES
         CALL "ZIP-READ-RANGE" USING L-HANDLE L-INDEX B-BUFFER WS-BYTES WS-LENGTH L-STATUS
         IF L-STATUS = FM-ZIP-OK
*>           The central record's CRC-32: bytes 17 to 20 of the record, which ends 46 bytes before the name.
             COMPUTE WS-HEADER = ZE-NAME-OFFSET(L-INDEX) - 46
             MOVE B-DATA(WS-HEADER + 16:4) TO WS-CRC-BYTES
             COMPUTE WS-CENTRAL = WS-CB(1) + WS-CB(2) * 256 + WS-CB(3) * 65536 + WS-CB(4) * 16777216
             MOVE 0 TO WS-CRC
             CALL "CRC32" USING B-BUFFER WS-LENGTH WS-CRC
             IF WS-CRC NOT = WS-CENTRAL
                 MOVE FM-ZIP-CRC TO L-STATUS
             END-IF
         END-IF
         FREE WS-BUFFER-ADDR
     END-IF
     GOBACK.
 END PROGRAM ZIP-CRC-CHECK.
