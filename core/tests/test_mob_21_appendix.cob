*> Entity metadata, own fields, of every entity type (docs/protocol/21 Appendix A, serializer ids of 00 section 13.2; lane 002-lane-p49i, T22500; phase task T2658).
*> Both documents are read at run time (the tests run from the repository root). Part 1 checks the appendix itself: every serializer name is one of the 44 of 00 13.2 and the own
*> fields of a row are numbered consecutively from the row's last inherited index + 1. Part 2 drives the core: every standard mob row (STDMOBS.cpy) is spawned with every
*> non-default state the entity data writers know about, the Set Entity Data entries of MOB-DATA-BUILD, STDMOB-VARIANT-BUILD and STDMOB-FIRE-BUILD are decoded, and each entry
*> above the inherited indexes must be an own field of the species' row with the serializer the row names. The orb, the primed TNT and the ground item are checked the same way.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-MOB-21-APPENDIX.
 ENVIRONMENT DIVISION.
 INPUT-OUTPUT SECTION.
 FILE-CONTROL.
     SELECT DOC-FILE ASSIGN TO "docs/protocol/21-mobs-aquatic-nether-end-bosses-and-entities.md" ORGANIZATION LINE SEQUENTIAL FILE STATUS WS-FS.
     SELECT SER-FILE ASSIGN TO "docs/protocol/00-data-types.md" ORGANIZATION LINE SEQUENTIAL FILE STATUS WS-FS2.
 DATA DIVISION.
 FILE SECTION.
 FD DOC-FILE.
 01 DOC-LINE               PIC X(800).
 FD SER-FILE.
 01 SER-LINE               PIC X(400).
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY STDMOBS.
 COPY PROTO REPLACING LEADING ==PB-== BY ==TP-==.
 01 WS-FS                  PIC XX.
 01 WS-FS2                 PIC XX.
 01 WS-SER.
    05 WS-SER-NAME         PIC X(40) OCCURS 44 TIMES.
 01 WS-SER-COUNT           BINARY-LONG VALUE 0.
 01 WS-AP.
    05 WS-AP-LINE          PIC X(800) OCCURS 160 TIMES.
 01 WS-AP-COUNT            BINARY-LONG VALUE 0.
 01 WS-STATE               BINARY-LONG VALUE 0.
 01 WS-I                   BINARY-LONG.
 01 WS-J                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-POS                 BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-C1                  PIC X(800).
 01 WS-C2                  PIC X(40).
 01 WS-C3                  PIC X(800).
 01 WS-C4                  PIC X(800).
 01 WS-FIELDS              PIC X(810).
 01 WS-ENTRY               PIC X(120).
 01 WS-SN                  PIC X(40).
 01 WS-SNID                BINARY-LONG.
 01 WS-IDX-TXT             PIC X(8).
 01 WS-IDX-NUM             PIC 9(4).
 01 WS-PAT                 PIC X(40).
 01 WS-PAT-LEN             BINARY-LONG.
 01 WS-LAST                BINARY-LONG.
 01 WS-LASTTXT             PIC X(8).
 01 WS-EXPECT-IDX          BINARY-LONG.
 01 WS-ROWOK               BINARY-LONG.
 01 WS-BAD                 BINARY-LONG.
 01 WS-KEY                 PIC X(40).
 01 WS-FOUND               BINARY-LONG.
 01 WS-ENT-NAME            PIC X(40).
 01 WS-EKEY                PIC X(112).
 01 WS-TYPE                BINARY-LONG.
 01 WS-ENTITY-ROW          PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-PLAYER              BINARY-LONG.
 01 WS-DIM                 BINARY-LONG.
 01 WS-FX                  FLOAT-LONG.
 01 WS-FY                  FLOAT-LONG.
 01 WS-FZ                  FLOAT-LONG.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-ROW                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 512.
 01 WS-PID                 BINARY-LONG.
 01 WS-EID                 BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-O                   BINARY-LONG.
 01 WS-CASE                PIC X(240).
 01 WS-INH                 BINARY-LONG.
 01 WS-SEEN                BINARY-LONG.
 01 WS-ITEM-ID             BINARY-LONG VALUE 1.
 01 WS-ITEM-COUNT          BINARY-LONG VALUE 3.
 01 WS-ORB-VALUE           BINARY-LONG VALUE 5.
 01 WS-TNT-FUSE            BINARY-LONG VALUE 40.
 01 WS-ONES                PIC X(16) VALUE "ABCDEFGHIJKLMNOP".
 01 WS-SPECIES             PIC X(24).
 01 WS-SER-DISP            PIC 99.
 01 WS-AGELESS             BINARY-LONG VALUE 1.
 01 WS-EM.
    05 WS-EMIT             PIC 9 OCCURS 64 TIMES.
 01 WS-B1                  BINARY-LONG.
 01 WS-B2                  BINARY-LONG.
 01 WS-NEEDED              BINARY-LONG.
 01 WS-IDX-EDIT            PIC ZZZ9.
 PROCEDURE DIVISION.
     MOVE "N" TO TL-MODE
     PERFORM LOAD-SERIALIZERS
     PERFORM LOAD-APPENDIX
     MOVE "acceptance US15 21§A the serializer table of 00 13.2 has 44 rows" TO WS-CASE
     MOVE 44 TO WS-E
     MOVE WS-SER-COUNT TO WS-O
     PERFORM CHECK-N
     MOVE "acceptance US15 21§A the appendix lists 140 rows" TO WS-CASE
     MOVE 140 TO WS-E
     MOVE WS-AP-COUNT TO WS-O
     PERFORM CHECK-N
*>   Part 1: the appendix rows.
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > WS-AP-COUNT
         PERFORM SPLIT-ROW
         PERFORM CHECK-ROW
     END-PERFORM
*>   Part 2: the core.
     CALL "MS-TEST-OPEN" USING WS-PLAYER
     MOVE PL-DIM(WS-PLAYER) TO WS-DIM
     MOVE PL-X(WS-PLAYER) TO WS-FX
     MOVE PL-Y(WS-PLAYER) TO WS-FY
     MOVE PL-Z(WS-PLAYER) TO WS-FZ
     PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > SM-COUNT
         MOVE SM-KEY(WS-K) TO WS-ENT-NAME
         PERFORM DO-SPECIES
     END-PERFORM
     PERFORM DO-NON-MOBS
     STOP RUN.

 LOAD-SERIALIZERS.
     OPEN INPUT SER-FILE
     IF WS-FS2 NOT = "00"
         DISPLAY "cannot open 00-data-types: " WS-FS2
         STOP RUN RETURNING 1
     END-IF
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE = 9
         READ SER-FILE
             AT END
                 MOVE 9 TO WS-STATE
         END-READ
         IF WS-STATE NOT = 9
             EVALUATE TRUE
                 WHEN WS-STATE = 0
                     IF SER-LINE(1:21) = "### 13.2 Serializer i"
                         MOVE 1 TO WS-STATE
                     END-IF
                 WHEN SER-LINE(1:3) = "## " OR SER-LINE(1:4) = "### "
                     MOVE 9 TO WS-STATE
                 WHEN SER-LINE(1:2) = "| " AND SER-LINE(3:1) >= "0" AND SER-LINE(3:1) <= "9"
                     MOVE SPACES TO WS-C1 WS-C2 WS-C3
                     UNSTRING SER-LINE DELIMITED BY " | " INTO WS-C1 WS-C2 WS-C3
                     ADD 1 TO WS-SER-COUNT
                     MOVE WS-C2 TO WS-SER-NAME(WS-SER-COUNT)
             END-EVALUATE
         END-IF
     END-PERFORM
     CLOSE SER-FILE.

 LOAD-APPENDIX.
     OPEN INPUT DOC-FILE
     IF WS-FS NOT = "00"
         DISPLAY "cannot open the document: " WS-FS
         STOP RUN RETURNING 1
     END-IF
     MOVE 0 TO WS-STATE
     PERFORM UNTIL WS-STATE = 9
         READ DOC-FILE
             AT END
                 MOVE 9 TO WS-STATE
         END-READ
         IF WS-STATE NOT = 9
             EVALUATE TRUE
                 WHEN WS-STATE = 0
                     IF DOC-LINE(1:15) = "## Appendix A. "
                         MOVE 1 TO WS-STATE
                     END-IF
                 WHEN DOC-LINE(1:3) = "| `"
                     ADD 1 TO WS-AP-COUNT
                     MOVE DOC-LINE TO WS-AP-LINE(WS-AP-COUNT)
             END-EVALUATE
         END-IF
     END-PERFORM
     CLOSE DOC-FILE.

*> SPLIT-ROW: row WS-I into WS-C1 (names cell), WS-C2 (last inherited index text) and WS-C3 (fields cell, trailing " |" removed, led by "; ").
 SPLIT-ROW.
     MOVE SPACES TO WS-C1 WS-C2 WS-C3 WS-C4
     UNSTRING WS-AP-LINE(WS-I) DELIMITED BY " | " INTO WS-C1 WS-C2 WS-C3 WS-C4
     MOVE SPACES TO WS-FIELDS
     IF WS-C3(1:1) = "-"
         MOVE SPACES TO WS-FIELDS
     ELSE
         COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-C3 TRAILING))
         IF WS-C3(WS-LEN - 1:2) = " |"
             COMPUTE WS-LEN = WS-LEN - 2
         END-IF
         STRING "; " DELIMITED BY SIZE WS-C3(1:WS-LEN) DELIMITED BY SIZE INTO WS-FIELDS
     END-IF.

*> CHECK-ROW: the fields of the row are consecutive from the inherited index + 1 and use serializers of the table.
 CHECK-ROW.
     MOVE WS-C2(1:2) TO WS-LASTTXT
     COMPUTE WS-LAST = FUNCTION NUMVAL(WS-LASTTXT)
     COMPUTE WS-EXPECT-IDX = WS-LAST + 1
     MOVE 0 TO WS-BAD
     MOVE 1 TO WS-POS
     MOVE 0 TO WS-N
     IF WS-FIELDS NOT = SPACES
         COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-FIELDS TRAILING))
         PERFORM UNTIL WS-POS > WS-LEN
             MOVE SPACES TO WS-ENTRY
             UNSTRING WS-FIELDS DELIMITED BY ";" INTO WS-ENTRY WITH POINTER WS-POS
             IF WS-ENTRY NOT = SPACES
                 PERFORM ENTRY-PARTS
                 IF WS-IDX-NUM NOT = WS-EXPECT-IDX
                     ADD 1 TO WS-BAD
                 END-IF
                 ADD 1 TO WS-EXPECT-IDX
                 IF WS-SNID < 0
                     ADD 1 TO WS-BAD
                 END-IF
             END-IF
         END-PERFORM
     END-IF
     MOVE FUNCTION TRIM(WS-C1) TO WS-CASE
     STRING "acceptance US15 21§A row " DELIMITED BY SIZE FUNCTION TRIM(WS-C1(3:60)) DELIMITED BY SIZE
         ": own fields are consecutive from the inherited index and use serializers of 00 13.2" DELIMITED BY SIZE INTO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-BAD TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> ENTRY-PARTS: WS-ENTRY (" 16 DATA_X BOOLEAN") into WS-IDX-NUM, WS-SN (the serializer name) and WS-SNID (its id, -1 when unknown).
 ENTRY-PARTS.
     MOVE FUNCTION TRIM(WS-ENTRY) TO WS-ENTRY
     MOVE 0 TO WS-IDX-NUM
     MOVE SPACES TO WS-IDX-TXT
     UNSTRING WS-ENTRY DELIMITED BY " " INTO WS-IDX-TXT
     COMPUTE WS-IDX-NUM = FUNCTION NUMVAL(WS-IDX-TXT)
     COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-ENTRY TRAILING))
     MOVE WS-LEN TO WS-J
     PERFORM UNTIL WS-J < 2 OR WS-ENTRY(WS-J:1) = " "
         SUBTRACT 1 FROM WS-J
     END-PERFORM
     MOVE SPACES TO WS-SN
     COMPUTE WS-N = WS-LEN - WS-J
     IF WS-ENTRY(WS-LEN - 1:2) = " |"
         COMPUTE WS-N = WS-N - 2
     END-IF
     MOVE WS-ENTRY(WS-J + 1:WS-N) TO WS-SN
     MOVE -1 TO WS-SNID
     PERFORM VARYING WS-N FROM 1 BY 1 UNTIL WS-N > WS-SER-COUNT
         IF WS-SER-NAME(WS-N) = WS-SN
             COMPUTE WS-SNID = WS-N - 1
         END-IF
     END-PERFORM.

*> FIND-ROW: the appendix row whose names cell lists WS-KEY in backticks; WS-FOUND = its number or 0; WS-INH its last inherited index.
 FIND-ROW.
     MOVE 0 TO WS-FOUND
     MOVE SPACES TO WS-PAT
     STRING "`" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE "`" DELIMITED BY SIZE INTO WS-PAT
     COMPUTE WS-PAT-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-PAT))
     PERFORM VARYING WS-J FROM 1 BY 1 UNTIL WS-J > WS-AP-COUNT OR WS-FOUND > 0
         MOVE 0 TO WS-N
         INSPECT WS-AP-LINE(WS-J) TALLYING WS-N FOR CHARACTERS BEFORE INITIAL " | "
         MOVE 0 TO WS-POS
         INSPECT WS-AP-LINE(WS-J)(1:WS-N) TALLYING WS-POS FOR ALL WS-PAT(1:WS-PAT-LEN)
         IF WS-POS > 0
             MOVE WS-J TO WS-FOUND
         END-IF
     END-PERFORM
     IF WS-FOUND > 0
         MOVE WS-FOUND TO WS-I
         PERFORM SPLIT-ROW
         MOVE WS-C2(1:2) TO WS-LASTTXT
         COMPUTE WS-INH = FUNCTION NUMVAL(WS-LASTTXT)
     END-IF.

*> CHECK-DECODED: decode the Set Entity Data entries of TP-BUFFER from its start (packet id and entity id first when WS-N2 = 1), compare each with the row found.
 DECODE-ENTRIES.
     MOVE 0 TO TP-POS
     CALL "PB-GET-VARINT" USING TP-BUFFER WS-PID
     CALL "PB-GET-VARINT" USING TP-BUFFER WS-EID
     INITIALIZE TP-METADATA-ENTRY-X
     CALL "PB-GET-METADATA-ENTRY-X" USING TP-BUFFER TP-METADATA-ENTRY-X
     PERFORM UNTIL TP-MX-INDEX = TP-MD-END OR TP-ERROR NOT = 0
         PERFORM CHECK-ENTRY
         INITIALIZE TP-METADATA-ENTRY-X
         CALL "PB-GET-METADATA-ENTRY-X" USING TP-BUFFER TP-METADATA-ENTRY-X
     END-PERFORM.

 CHECK-ENTRY.
     IF TP-MX-INDEX > WS-INH
         MOVE SPACES TO WS-PAT
         MOVE TP-MX-INDEX TO WS-IDX-EDIT
         MOVE WS-IDX-EDIT TO WS-IDX-TXT
         STRING "; " DELIMITED BY SIZE FUNCTION TRIM(WS-IDX-TXT) DELIMITED BY SIZE " " DELIMITED BY SIZE INTO WS-PAT
         COMPUTE WS-PAT-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-PAT TRAILING)) + 1
         MOVE 0 TO WS-N
         INSPECT WS-FIELDS TALLYING WS-N FOR CHARACTERS BEFORE INITIAL WS-PAT(1:WS-PAT-LEN)
         COMPUTE WS-LEN = FUNCTION LENGTH(FUNCTION TRIM(WS-FIELDS TRAILING))
         MOVE 0 TO WS-O
         IF WS-N < WS-LEN
             COMPUTE WS-POS = WS-N + 3
             MOVE SPACES TO WS-ENTRY
             UNSTRING WS-FIELDS(WS-POS:) DELIMITED BY ";" INTO WS-ENTRY
             PERFORM ENTRY-PARTS
             IF WS-SNID = TP-MX-SERIALIZER
                 MOVE 1 TO WS-O
             END-IF
         END-IF
         MOVE TP-MX-INDEX TO WS-IDX-NUM
         MOVE TP-MX-SERIALIZER TO WS-SER-DISP
         MOVE SPACES TO TL-CASE
         STRING "acceptance US15 21§A " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE
             " metadata " DELIMITED BY SIZE WS-IDX-NUM DELIMITED BY SIZE " serializer " DELIMITED BY SIZE
             WS-SER-DISP DELIMITED BY SIZE " is an own field with that serializer" DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-O TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         ADD 1 TO WS-SEEN
         MOVE 1 TO WS-EMIT(TP-MX-INDEX + 1)
     END-IF.

 DO-SPECIES.
     MOVE WS-ENT-NAME TO WS-KEY
     PERFORM FIND-ROW
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 21§A " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE
         " has a row in the appendix" DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE 0 TO TL-OBSERVED-N
     IF WS-FOUND > 0
         MOVE 1 TO TL-OBSERVED-N
     END-IF
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     IF WS-FOUND > 0
         MOVE SPACES TO WS-EKEY
         STRING "minecraft:" DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE INTO WS-EKEY
         CALL "CONTENT-ENTITY-BY-KEY" USING WS-EKEY WS-TYPE WS-ENTITY-ROW WS-STATUS
         CALL "MOB-SPAWN" USING WS-DIM WS-TYPE WS-FX WS-FY WS-FZ WS-YAW WS-ROW
         IF WS-ROW > 0
             PERFORM SET-STATES
             PERFORM BUILD-AND-DECODE
             PERFORM EXPECT-STATES
         END-IF
     END-IF.

*> SET-STATES: every state the entity data writers look at, non-default.
 SET-STATES.
     MOVE 1 TO EN-VARIANT(WS-ROW)
     IF SM-KIND(WS-K) = 0
         MOVE 0 TO WS-N
         INSPECT WS-FIELDS TALLYING WS-N FOR ALL "DATA_BABY_ID"
         IF WS-N = 0
             MOVE 0 TO EN-VARIANT(WS-ROW)
             MOVE 0 TO WS-AGELESS
         ELSE
             MOVE 1 TO WS-AGELESS
         END-IF
     END-IF
     MOVE 1 TO EN-WOOL(WS-ROW)
     MOVE 1 TO EN-TAMED(WS-ROW)
     MOVE WS-ONES TO EN-OWNER-UUID(WS-ROW)
     MOVE 1 TO EN-SIT(WS-ROW)
     MOVE 5 TO EN-BOOST(WS-ROW)
     MOVE 1 TO EN-COLD(WS-ROW)
     MOVE 1 TO EN-ARMA(WS-ROW)
     MOVE 1 TO EN-SNIF(WS-ROW)
     MOVE 2 TO EN-STRENGTH(WS-ROW)
     MOVE 1 TO EN-ALLAY-DUP(WS-ROW)
     MOVE 1 TO EN-ALLAY-DANCE(WS-ROW)
     MOVE 1 TO EN-FOX-FLAGS(WS-ROW)
     MOVE WS-ONES TO EN-FOX-TRUST-A(WS-ROW)
     MOVE WS-ONES TO EN-FOX-TRUST-B(WS-ROW)
     MOVE 1 TO EN-GENE-MAIN(WS-ROW)
     MOVE 1 TO EN-GENE-HIDDEN(WS-ROW)
     MOVE 1 TO EN-PANDA-SNEEZE(WS-ROW)
     MOVE 1 TO EN-PANDA-FLAGS(WS-ROW)
     MOVE 1 TO EN-PANDA-EAT(WS-ROW)
     MOVE 1 TO EN-TURTLE-EGG(WS-ROW)
     MOVE 1 TO EN-TURTLE-LAY(WS-ROW)
     MOVE WS-AGELESS TO EN-LOCKED(WS-ROW)
     MOVE 1 TO EN-TONGUE(WS-ROW)
     MOVE 1 TO EN-BEE-ROLL(WS-ROW)
     MOVE 1 TO EN-BEE-STUNG(WS-ROW)
     MOVE 1 TO EN-BEE-NECTAR(WS-ROW)
     MOVE 1 TO EN-IGNITED(WS-ROW)
     MOVE 40 TO EN-BURN(WS-ROW).

 BUILD-AND-DECODE.
*>   The entity view (ENTITY-VIEW-UPDATE) sends MOB-DATA-BUILD for a passive row only (SM-KIND 0) and STDMOB-VARIANT-BUILD for the others.
     MOVE 0 TO WS-SEEN
     MOVE ALL "0" TO WS-EM
     CALL "MOB-DATA-VALUES" USING WS-ROW WS-B1 WS-B2 WS-NEEDED
     IF WS-NEEDED = 1
         CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
         CALL "MOB-DATA-BUILD" USING WS-ROW TP-BUFFER
         PERFORM DECODE-ENTRIES
         CALL "PB-FREE" USING TP-BUFFER
     END-IF
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "STDMOB-VARIANT-BUILD" USING WS-ROW TP-BUFFER
     IF TP-LENGTH > 0
         PERFORM DECODE-ENTRIES
     END-IF
     CALL "PB-FREE" USING TP-BUFFER.

 EXPECT-STATES.
*>   Non-default own fields the core models and must send: the age lock of an ageable animal (17), the mooshroom type (18), the creeper's ignition (18).
     EVALUATE WS-KEY
         WHEN "pig"
             MOVE 17 TO WS-J
             PERFORM EXPECT-EMITTED
         WHEN "sheep"
             MOVE 17 TO WS-J
             PERFORM EXPECT-EMITTED
         WHEN "mooshroom"
             MOVE 17 TO WS-J
             PERFORM EXPECT-EMITTED
             MOVE 18 TO WS-J
             PERFORM EXPECT-EMITTED
         WHEN "creeper"
             MOVE 18 TO WS-J
             PERFORM EXPECT-EMITTED
     END-EVALUATE.

 EXPECT-EMITTED.
     MOVE WS-J TO WS-IDX-EDIT
     MOVE SPACES TO TL-CASE
     STRING "acceptance US15 21§A " DELIMITED BY SIZE FUNCTION TRIM(WS-KEY) DELIMITED BY SIZE
         " in a non-default state sends metadata " DELIMITED BY SIZE FUNCTION TRIM(WS-IDX-EDIT) DELIMITED BY SIZE INTO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE WS-EMIT(WS-J + 1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 DO-NON-MOBS.
*>   The orb: 8 INT.
     MOVE "experience_orb" TO WS-KEY
     PERFORM FIND-ROW
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     MOVE 1 TO WS-EID
     CALL "SET-ENTITY-DATA-ORB-BUILD" USING WS-EID WS-ORB-VALUE TP-BUFFER
     PERFORM DECODE-ENTRIES
     CALL "PB-FREE" USING TP-BUFFER
*>   The primed TNT: 8 INT (the fuse).
     MOVE "tnt" TO WS-KEY
     PERFORM FIND-ROW
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "SET-ENTITY-DATA-FUSE-BUILD" USING WS-EID WS-TNT-FUSE TP-BUFFER
     PERFORM DECODE-ENTRIES
     CALL "PB-FREE" USING TP-BUFFER
*>   The ground item: 8 ITEM_STACK.
     MOVE "item" TO WS-KEY
     PERFORM FIND-ROW
     CALL "PB-INIT" USING TP-BUFFER WS-CAPACITY
     CALL "SET-ENTITY-DATA-ITEM-BUILD" USING WS-EID WS-ITEM-ID WS-ITEM-COUNT TP-BUFFER
     PERFORM DECODE-ENTRIES
     CALL "PB-FREE" USING TP-BUFFER.

 CHECK-N.
     MOVE WS-CASE TO TL-CASE
     MOVE WS-E TO TL-EXPECTED-N
     MOVE WS-O TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.
 END PROGRAM TEST-MOB-21-APPENDIX.
 COPY CORETEST.
 COPY MOBSPTEST.
