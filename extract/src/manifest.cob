*> The files the tool writes besides the packs' payload (22 §6.2, §6.4, §6.5, §7.5).
*>   EX-INDEX-RESET     (no parameters) releases the index buffer and starts an empty index.
*>   EX-INDEX-ADD       USING crc (BINARY-LONG UNSIGNED), size (BINARY-LONG), path (PIC X(1100)), status out (0, or 45
*>                      when the line does not fit the 16 MiB buffer, assumption A6): appends "<crc> <size> <path>" LF.
*>   EX-WRITE-INDEX     USING directory (PIC X(1100)), status out (0, or 50): writes <directory>/index.txt from the buffer,
*>                      then releases it.
*>   EX-WRITE-MANIFEST  USING directory, status out (0, or 50): writes <directory>/manifest.txt for the identified row
*>                      (EXC-ROW of EX-CHK) and the counts of EX-RES.
*>   EX-WRITE-MCMETA    USING directory, status out (0, or 50): writes vanilla-resources/pack.mcmeta and
*>                      vanilla-data/pack.mcmeta below the directory (the text of 22 §6.2 for the row's formats) and adds
*>                      their index lines.
*>   EX-WRITE-MARKER    USING directory, status out (0, or 50): makes the directory and its empty .cobolcraft-generated.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-INDEX-RESET.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 PROCEDURE DIVISION.
     IF EXI-ADDR NOT = NULL
         FREE EXI-ADDR
     END-IF
     SET EXI-ADDR TO NULL
     MOVE 0 TO EXI-LENGTH EXI-LINES
     GOBACK.
 END PROGRAM EX-INDEX-RESET.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-INDEX-ADD.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 01 B-INDEX                PIC X(16777216) BASED.
 01 WS-LINE                PIC X(1200).
 01 WS-LINE-LENGTH         BINARY-LONG.
 01 WS-POINTER             BINARY-LONG.
 01 WS-CRC-HEX             PIC X(8).
 01 WS-SIZE                BINARY-DOUBLE.
 01 WS-SIZE-TEXT           PIC X(20).
 01 WS-CODE                BINARY-LONG.
 01 WS-CAPACITY-TEXT       PIC X(20).
 01 WS-CAPACITY            BINARY-DOUBLE VALUE EXI-CAPACITY.
 LINKAGE SECTION.
 01 L-CRC                  BINARY-LONG UNSIGNED.
 01 L-SIZE                 BINARY-LONG.
 01 L-PATH                 PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-CRC L-SIZE L-PATH L-STATUS.
     MOVE 0 TO L-STATUS
     IF EXI-ADDR = NULL
         ALLOCATE EXI-CAPACITY CHARACTERS RETURNING EXI-ADDR
         MOVE 0 TO EXI-LENGTH EXI-LINES
     END-IF
     CALL "EX-HEX8" USING L-CRC WS-CRC-HEX
     MOVE L-SIZE TO WS-SIZE
     CALL "EX-NUM" USING WS-SIZE WS-SIZE-TEXT
     MOVE SPACES TO WS-LINE
     MOVE 1 TO WS-POINTER
     STRING WS-CRC-HEX " " FUNCTION TRIM(WS-SIZE-TEXT) " " FUNCTION TRIM(L-PATH) X"0A"
         DELIMITED BY SIZE INTO WS-LINE POINTER WS-POINTER
     COMPUTE WS-LINE-LENGTH = WS-POINTER - 1
     IF EXI-LENGTH + WS-LINE-LENGTH > EXI-CAPACITY
         CALL "EX-NUM" USING WS-CAPACITY WS-CAPACITY-TEXT
         MOVE SPACES TO EXM-ARG(1)
         STRING "the index is larger than " FUNCTION TRIM(WS-CAPACITY-TEXT) " bytes" DELIMITED BY SIZE
             INTO EXM-ARG(1)
         MOVE 45 TO WS-CODE L-STATUS
         CALL "EX-SAY" USING WS-CODE
         GOBACK
     END-IF
     SET ADDRESS OF B-INDEX TO EXI-ADDR
     MOVE WS-LINE(1:WS-LINE-LENGTH) TO B-INDEX(EXI-LENGTH + 1:WS-LINE-LENGTH)
     ADD WS-LINE-LENGTH TO EXI-LENGTH
     ADD 1 TO EXI-LINES
     GOBACK.
 END PROGRAM EX-INDEX-ADD.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-WRITE-INDEX.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 01 B-INDEX                PIC X BASED.
 01 WS-NAME                PIC X(1100) VALUE "index.txt".
 01 WS-PATH                PIC X(1100).
 01 WS-NOTHING             PIC X.
 01 WS-NONE                BINARY-LONG VALUE 0.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     CALL "EX-JOIN" USING L-DIR WS-NAME WS-PATH
     IF EXI-ADDR = NULL
         CALL "EX-PUT" USING WS-PATH WS-NOTHING WS-NONE L-STATUS
     ELSE
         SET ADDRESS OF B-INDEX TO EXI-ADDR
         CALL "EX-PUT" USING WS-PATH B-INDEX EXI-LENGTH L-STATUS
     END-IF
     CALL "EX-INDEX-RESET"
     GOBACK.
 END PROGRAM EX-WRITE-INDEX.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-WRITE-MANIFEST.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 01 WS-NAME                PIC X(1100) VALUE "manifest.txt".
 01 WS-PATH                PIC X(1100).
 01 WS-TEXT                PIC X(1024).
 01 WS-POINTER             BINARY-LONG.
 01 WS-LENGTH              BINARY-LONG.
 01 WS-NUMBER              BINARY-DOUBLE.
 01 WS-RESOURCE            PIC X(20).
 01 WS-DATA                PIC X(20).
 01 WS-FEATURE             PIC X(20).
 01 WS-TOTAL               PIC X(20).
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     MOVE EXR-RESOURCE TO WS-NUMBER
     CALL "EX-NUM" USING WS-NUMBER WS-RESOURCE
     MOVE EXR-DATA TO WS-NUMBER
     CALL "EX-NUM" USING WS-NUMBER WS-DATA
     MOVE EXR-FEATURE TO WS-NUMBER
     CALL "EX-NUM" USING WS-NUMBER WS-FEATURE
     MOVE EXR-TOTAL TO WS-NUMBER
     CALL "EX-NUM" USING WS-NUMBER WS-TOTAL
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POINTER
*>   The row: version id 1-4, size 5-12, SHA-256 13-76, world 77-80, protocol 81-83, resource format 84-87, data format 88-92.
     STRING "format=1" X"0A" "tool=cobolcraft-extract 1" X"0A"
         "jar-version=" FUNCTION TRIM(EXC-ROW(1:4)) X"0A"
         "jar-sha256=" EXC-ROW(13:64) X"0A"
         "jar-size=" FUNCTION TRIM(EXC-ROW(5:8)) X"0A"
         "world-version=" FUNCTION TRIM(EXC-ROW(77:4)) X"0A"
         "protocol-version=" FUNCTION TRIM(EXC-ROW(81:3)) X"0A"
         "resource-format=" FUNCTION TRIM(EXC-ROW(84:4)) X"0A"
         "data-format=" FUNCTION TRIM(EXC-ROW(88:5)) X"0A"
         "files-resource=" FUNCTION TRIM(WS-RESOURCE) X"0A"
         "files-data=" FUNCTION TRIM(WS-DATA) X"0A"
         "files-feature=" FUNCTION TRIM(WS-FEATURE) X"0A"
         "files-total=" FUNCTION TRIM(WS-TOTAL) X"0A"
         DELIMITED BY SIZE INTO WS-TEXT POINTER WS-POINTER
     COMPUTE WS-LENGTH = WS-POINTER - 1
     CALL "EX-JOIN" USING L-DIR WS-NAME WS-PATH
     CALL "EX-PUT" USING WS-PATH WS-TEXT WS-LENGTH L-STATUS
     GOBACK.
 END PROGRAM EX-WRITE-MANIFEST.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-MCMETA-TEXT.
*> USING pack (BINARY-LONG: 1 resource pack, 2 data pack), format (PIC X(5): "97.1", "121.0"), text out (PIC X(512)),
*> length out (BINARY-LONG): the pack.mcmeta of 22 §6.2 for that format range, from its own major.minor up to its major.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 01 WS-DESCRIPTIONS.
    05 FILLER              PIC X(40) VALUE "The default look and feel of Minecraft".
    05 FILLER              PIC X(40) VALUE "The default data for Minecraft".
 01 WS-DESCRIPTION-TABLE REDEFINES WS-DESCRIPTIONS.
    05 WS-DESCRIPTION      PIC X(40) OCCURS 2 TIMES.
 01 WS-MAJOR               PIC X(5).
 01 WS-MINOR               PIC X(5).
 01 WS-POINTER             BINARY-LONG.
 LINKAGE SECTION.
 01 L-PACK                 BINARY-LONG.
 01 L-FORMAT               PIC X(5).
 01 L-TEXT                 PIC X(512).
 01 L-LENGTH               BINARY-LONG.
 PROCEDURE DIVISION USING L-PACK L-FORMAT L-TEXT L-LENGTH.
     MOVE SPACES TO WS-MAJOR WS-MINOR L-TEXT
     UNSTRING L-FORMAT DELIMITED BY "." INTO WS-MAJOR WS-MINOR
     MOVE 1 TO WS-POINTER
     STRING "{" X"0A" '  "pack": {' X"0A" '    "description": "' FUNCTION TRIM(WS-DESCRIPTION(L-PACK)) '",' X"0A"
         '    "min_format": [' FUNCTION TRIM(WS-MAJOR) ", " FUNCTION TRIM(WS-MINOR) "]," X"0A"
         '    "max_format": ' FUNCTION TRIM(WS-MAJOR) X"0A" "  }" X"0A" "}" X"0A"
         DELIMITED BY SIZE INTO L-TEXT POINTER WS-POINTER
     COMPUTE L-LENGTH = WS-POINTER - 1
     GOBACK.
 END PROGRAM EX-MCMETA-TEXT.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-WRITE-MCMETA.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-FOLDERS.
    05 FILLER              PIC X(1100) VALUE "vanilla-resources".
    05 FILLER              PIC X(1100) VALUE "vanilla-data".
 01 WS-FOLDER-TABLE REDEFINES WS-FOLDERS.
    05 WS-FOLDER           PIC X(1100) OCCURS 2 TIMES.
 01 WS-FILES.
    05 FILLER              PIC X(1100) VALUE "vanilla-resources/pack.mcmeta".
    05 FILLER              PIC X(1100) VALUE "vanilla-data/pack.mcmeta".
 01 WS-FILE-TABLE REDEFINES WS-FILES.
    05 WS-FILE             PIC X(1100) OCCURS 2 TIMES.
 01 WS-NAME                PIC X(1100) VALUE "pack.mcmeta".
 01 WS-I                   BINARY-LONG.
 01 WS-FORMAT              PIC X(5).
 01 WS-DIR-PATH            PIC X(1100).
 01 WS-PATH                PIC X(1100).
 01 WS-TEXT                PIC X(512).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-CRC                 BINARY-LONG UNSIGNED.
 01 WS-FILE-STATUS         BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-INDEX-STATUS        BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     MOVE 0 TO L-STATUS
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 2 OR L-STATUS NOT = 0
         CALL "EX-JOIN" USING L-DIR WS-FOLDER(WS-I) WS-DIR-PATH
         CALL "DIR-ENSURE" USING WS-DIR-PATH WS-FILE-STATUS
         IF WS-FILE-STATUS NOT = FM-OK
             MOVE SPACES TO EXM-ARG(1) EXM-ARG(2)
             MOVE WS-DIR-PATH TO EXM-ARG(1)
             MOVE "cannot be created or written" TO EXM-ARG(2)
             MOVE 50 TO WS-CODE L-STATUS
             CALL "EX-SAY" USING WS-CODE
         END-IF
         IF L-STATUS = 0
*>           Resource pack: the row's resource format (84-87); data pack: its data format (88-92).
             IF WS-I = 1
                 MOVE EXC-ROW(84:4) TO WS-FORMAT
             ELSE
                 MOVE EXC-ROW(88:5) TO WS-FORMAT
             END-IF
             CALL "EX-MCMETA-TEXT" USING WS-I WS-FORMAT WS-TEXT WS-LENGTH
             CALL "EX-JOIN" USING WS-DIR-PATH WS-NAME WS-PATH
             CALL "EX-PUT" USING WS-PATH WS-TEXT WS-LENGTH L-STATUS
         END-IF
         IF L-STATUS = 0
             ADD WS-LENGTH TO EXR-BYTES
             MOVE 0 TO WS-CRC
             CALL "CRC32" USING WS-TEXT WS-LENGTH WS-CRC
             CALL "EX-INDEX-ADD" USING WS-CRC WS-LENGTH WS-FILE(WS-I) L-STATUS
         END-IF
     END-PERFORM
     GOBACK.
 END PROGRAM EX-WRITE-MCMETA.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. EX-WRITE-MARKER.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY EXSTATE.
 COPY FORMATS.
 01 WS-NAME                PIC X(1100) VALUE ".cobolcraft-generated".
 01 WS-PATH                PIC X(1100).
 01 WS-NOTHING             PIC X.
 01 WS-NONE                BINARY-LONG VALUE 0.
 01 WS-FILE-STATUS         BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 LINKAGE SECTION.
 01 L-DIR                  PIC X(1100).
 01 L-STATUS               BINARY-LONG.
 PROCEDURE DIVISION USING L-DIR L-STATUS.
     MOVE 0 TO L-STATUS
     CALL "DIR-ENSURE" USING L-DIR WS-FILE-STATUS
     IF WS-FILE-STATUS NOT = FM-OK
         MOVE SPACES TO EXM-ARG(1) EXM-ARG(2)
         MOVE L-DIR TO EXM-ARG(1)
         MOVE "cannot be created or written" TO EXM-ARG(2)
         MOVE 50 TO WS-CODE L-STATUS
         CALL "EX-SAY" USING WS-CODE
         GOBACK
     END-IF
     CALL "EX-JOIN" USING L-DIR WS-NAME WS-PATH
     CALL "EX-PUT" USING WS-PATH WS-NOTHING WS-NONE L-STATUS
     GOBACK.
 END PROGRAM EX-WRITE-MARKER.
