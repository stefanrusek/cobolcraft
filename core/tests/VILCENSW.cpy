*> Working storage of the template census of the village and outpost tests (36-structures-9 sections 9, 10, 11, 13): the list of every structure template below village/ and pillager_outpost/ of a
*> data folder (VC-COLLECT in VILCENSP.cpy walks the folders with cc_fs_list), and the scratch of one folder listing. COPY it in WORKING-STORAGE; COPY VILCENSP in the PROCEDURE DIVISION.
 01 VC-ROOT                PIC X(1100).
 01 VC-BASE                PIC X(40) VALUE "structure".
 01 VC-EXT                 PIC X(5) VALUE ".nbt".
 01 VC-EXT-LEN             BINARY-LONG VALUE 4.
 01 VC-TPL-N               BINARY-LONG.
 01 VC-TPLS.
    05 VC-TPL              PIC X(96) OCCURS 600 TIMES.
 01 VC-DIR-N               BINARY-LONG.
 01 VC-DIRS.
    05 VC-DIR              PIC X(96) OCCURS 128 TIMES.
 01 VC-DIR-I               BINARY-LONG.
 01 VC-PATH                PIC X(1100).
 01 VC-PATHZ               PIC X(1101).
 01 VC-LIST                PIC X(65536).
 01 VC-LIST-COUNT          BINARY-LONG.
 01 VC-CAPACITY            BINARY-LONG VALUE 65536.
 01 VC-RC                  BINARY-LONG.
 01 VC-ENTRY               PIC X(120).
 01 VC-ENTRY-LEN           BINARY-LONG.
 01 VC-PTR                 BINARY-LONG.
 01 VC-K                   BINARY-LONG.
 01 VC-NAME                PIC X(96).
 01 VC-NAME-LEN            BINARY-LONG.
