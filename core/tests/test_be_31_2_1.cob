*> Test of 31-2 section 1 (Registration summary; T0867): the eleven block entity types of document 31-2, their registry ids, container sizes, default names, tickers and base classes (BE2-REGISTRATION), and their single valid block each.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-BE-31-2-1.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY CORESTATE.
 COPY BESTATE.
 COPY PROTO.
 COPY COREAPI.
 COPY CITEMS.
 01 WS-TEXT                PIC X(8192).
 01 WS-OUT                 PIC X(8192).
 01 WS-EDIT                PIC -(9)9.
 01 WS-EDIT2               PIC -(9)9.
 01 WS-EDIT3               PIC -(9)9.
 01 WS-I                   BINARY-LONG.
 01 WS-K                   BINARY-LONG.
 01 WS-LEN                 BINARY-LONG.
 01 WS-IDX                 BINARY-LONG.
 01 WS-PTR                 BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 4096.
 01 WS-TYPE10              BINARY-LONG VALUE 10.
 01 WS-FORM                BINARY-LONG VALUE 2.
 01 WS-D                   BINARY-LONG VALUE 1.
 01 WS-X                   BINARY-LONG VALUE 5.
 01 WS-Y                   BINARY-LONG VALUE 70.
 01 WS-Z                   BINARY-LONG VALUE 5.
 01 WS-T                   BINARY-LONG.
 01 WS-KEY                 PIC X(48).
 01 WS-KEY24               PIC X(24).
 01 WS-KEY32               PIC X(32).
 01 WS-NAME                PIC X(32).
 01 WS-ITEM                BINARY-LONG.
 01 WS-COUNT               BINARY-LONG.
 01 WS-VAR                 BINARY-LONG.
 01 WS-A                   BINARY-LONG.
 01 WS-B                   BINARY-LONG.
 01 WS-C                   BINARY-LONG.
 01 WS-HOPPER              BINARY-LONG.
 01 WS-DISPENSER           BINARY-LONG.
 01 WS-DROPPER             BINARY-LONG.
 01 WS-ROWS.
    05 FILLER PIC X(18) VALUE "furnace           ".
    05 FILLER PIC X(18) VALUE "dispenser         ".
    05 FILLER PIC X(18) VALUE "dropper           ".
    05 FILLER PIC X(18) VALUE "brewing_stand     ".
    05 FILLER PIC X(18) VALUE "daylight_detector ".
    05 FILLER PIC X(18) VALUE "hopper            ".
    05 FILLER PIC X(18) VALUE "comparator        ".
    05 FILLER PIC X(18) VALUE "smoker            ".
    05 FILLER PIC X(18) VALUE "blast_furnace     ".
    05 FILLER PIC X(18) VALUE "chiseled_bookshelf".
    05 FILLER PIC X(18) VALUE "crafter           ".
 01 FILLER REDEFINES WS-ROWS.
    05 WS-ROW-KEY          PIC X(18) OCCURS 11 TIMES.
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     MOVE "minecraft:hopper" TO WS-KEY
     MOVE 16 TO WS-LEN
     MOVE 18 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-HOPPER
     ADD 1 TO WS-X
     MOVE "minecraft:dispenser" TO WS-KEY
     MOVE 19 TO WS-LEN
     MOVE 5 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-DISPENSER
     ADD 1 TO WS-X
     MOVE "minecraft:dropper" TO WS-KEY
     MOVE 17 TO WS-LEN
     MOVE 6 TO WS-T
     CALL "BE-CREATE" USING WS-D WS-X WS-Y WS-Z WS-T WS-KEY WS-LEN WS-DROPPER
     MOVE "T" TO TL-MODE
     MOVE "acceptance US12 31-2§1 Registration summary the 11 types have the registry ids of 46 (furnace 0 ... hopper 18 ... smoker 27, blast_furnace 28, chiseled_bookshelf 38, crafter 42)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-ROW-KEY(WS-I) TO WS-KEY24
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY24)) TO WS-LEN
         CALL "BE-TYPE-ID" USING WS-KEY24 WS-LEN WS-T
         CALL "BE2-REGISTRATION" USING WS-T WS-A WS-KEY32 WS-LEN WS-B WS-C
         MOVE WS-T TO WS-EDIT
         STRING FUNCTION TRIM(WS-KEY24) " " FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE "furnace 0 dispenser 5 dropper 6 brewing_stand 12 daylight_detector 17 hopper 18 comparator 19 smoker 27 blast_furnace 28 chiseled_bookshelf 38 crafter 42 " TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-2§1 Registration summary the container sizes are 3, 9, 9, 5, none, 5, none, 3, 3, 6, 9" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-ROW-KEY(WS-I) TO WS-KEY24
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY24)) TO WS-LEN
         CALL "BE-TYPE-ID" USING WS-KEY24 WS-LEN WS-T
         CALL "BE2-REGISTRATION" USING WS-T WS-A WS-KEY32 WS-LEN WS-B WS-C
         MOVE WS-A TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE "3 9 9 5 -1 5 -1 3 3 6 9 " TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-2§1 Registration summary the default name keys (none for the comparator, the daylight detector and the chiseled bookshelf)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-ROW-KEY(WS-I) TO WS-KEY24
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY24)) TO WS-LEN
         CALL "BE-TYPE-ID" USING WS-KEY24 WS-LEN WS-T
         CALL "BE2-REGISTRATION" USING WS-T WS-A WS-KEY32 WS-LEN WS-B WS-C
         IF WS-LEN > 0
             STRING WS-KEY32(1:WS-LEN) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         ELSE
             STRING "- " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
         END-IF
     END-PERFORM
     MOVE "container.furnace container.dispenser container.dropper container.brewing - container.hopper - container.smoker container.blast_furnace - container.crafter " TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-2§1 Registration summary the server tickers: furnaces 1, brewing stand 2, hopper 3, crafter 4, the daylight detector's is the block's (6), the others none" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-ROW-KEY(WS-I) TO WS-KEY24
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY24)) TO WS-LEN
         CALL "BE-TYPE-ID" USING WS-KEY24 WS-LEN WS-T
         CALL "BE2-REGISTRATION" USING WS-T WS-A WS-KEY32 WS-LEN WS-B WS-C
         MOVE WS-B TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE "1 0 0 2 6 3 0 1 1 0 4 " TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-2§1 Registration summary base classes: furnaces and the brewing stand are base containers (1), hopper, dispenser, dropper and crafter randomizable (2), the rest plain (0)" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-ROW-KEY(WS-I) TO WS-KEY24
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY24)) TO WS-LEN
         CALL "BE-TYPE-ID" USING WS-KEY24 WS-LEN WS-T
         CALL "BE2-REGISTRATION" USING WS-T WS-A WS-KEY32 WS-LEN WS-B WS-C
         MOVE WS-C TO WS-EDIT
         STRING FUNCTION TRIM(WS-EDIT) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR
     END-PERFORM
     MOVE "1 2 2 1 0 2 0 1 1 0 2 " TO TL-EXPECTED
     PERFORM CHECK

     MOVE "acceptance US12 31-2§1 Registration summary each type has exactly one valid block, the block of the same name" TO TL-CASE
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-PTR
     MOVE 0 TO WS-A
     MOVE 0 TO WS-B
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-ROW-KEY(WS-I) TO WS-KEY24
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-KEY24)) TO WS-LEN
         CALL "BE-TYPE-ID" USING WS-KEY24 WS-LEN WS-T
         PERFORM VARYING WS-K FROM 1 BY 1 UNTIL WS-K > 11
             MOVE SPACES TO WS-KEY
             STRING "minecraft:" FUNCTION TRIM(WS-ROW-KEY(WS-K)) DELIMITED BY SIZE INTO WS-KEY
             COMPUTE WS-C = FUNCTION LENGTH(FUNCTION TRIM(WS-ROW-KEY(WS-K))) + 10
             CALL "BE-VALID-BLOCK" USING WS-T WS-KEY WS-C WS-ITEM
             IF WS-K = WS-I
                 ADD WS-ITEM TO WS-A
             ELSE
                 ADD WS-ITEM TO WS-B
             END-IF
         END-PERFORM
     END-PERFORM
     MOVE WS-A TO WS-EDIT
     MOVE WS-B TO WS-EDIT2
     STRING FUNCTION TRIM(WS-EDIT) " " FUNCTION TRIM(WS-EDIT2) DELIMITED BY SIZE INTO WS-TEXT
     MOVE "11 0" TO TL-EXPECTED
     PERFORM CHECK

     GOBACK.

 CHECK.
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

*> Saves entity WS-IDX in form WS-FORM and appends the rendered compound to WS-TEXT.
 SAVE-RENDER.
     CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
     CALL "BE-SAVE" USING WS-IDX WS-FORM PB-BUFFER
     CALL "NBT-WRITE-COMPOUND-END" USING PB-BUFFER
     MOVE 0 TO PB-POS
     MOVE 0 TO WS-LEN
     MOVE SPACES TO WS-OUT
     CALL "TEST-NBT-RENDER" USING PB-BUFFER WS-TYPE10 WS-OUT WS-LEN
     CALL "PB-FREE" USING PB-BUFFER
     STRING WS-OUT(1:WS-LEN) " " DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-PTR.
 END PROGRAM TEST-BE-31-2-1.

 COPY CORETEST.
