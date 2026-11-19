*> T60900 (lane 002-lane-bugrabbit, operator try18 "rabbits still no skin"): the model row of the rabbit named a texture that no pack has
*> (textures/entity/rabbit/brown.png; the vanilla files are rabbit_<name>.png, 34-4 12.3), so a rabbit whose variant the client does not know yet
*> (no Set Entity Data entry, EN-VAR -1, texture code 0: the row's own image) was drawn with the missing-texture stripes. With the real generated
*> vanilla pack (CC_GENERATED_DIR) every rabbit, adult and baby, with no variant and with the variants 0 to 5 and 99 (killer bunny), is drawn from the
*> atlas slot that holds exactly the pack image of the file its variant names (a variant not known is the default brown, 34-4 12.3); the first vertex
*> of the mesh takes its v from inside that slot (the stand-in stripes are not the pack's image, so the comparison fails on a missing texture).
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-ENTITY-RABBIT-SKIN.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY CLSTATE.
 COPY CLCONST.
 COPY CONTENT.
 COPY CLMODELS.
 COPY TESTLIB.
 01 WS-GEN                 PIC X(256).
 01 WS-ROOT                PIC X(256).
 01 WS-KEY                 PIC X(112).
 01 WS-ROW-AREA            PIC X(66).
 01 WS-STATUS              BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-ID                  BINARY-LONG VALUE 1.
 01 WS-X                   FLOAT-LONG VALUE 10.5.
 01 WS-Y                   FLOAT-LONG VALUE 64.
 01 WS-Z                   FLOAT-LONG VALUE 10.5.
 01 WS-YAW                 FLOAT-SHORT VALUE 0.
 01 WS-CASE                BINARY-LONG.
 01 WS-CASE-D              PIC 99.
 01 WS-BABY                BINARY-LONG.
 01 WS-V                   BINARY-LONG.
 01 WS-R                   BINARY-LONG.
 01 WS-W                   BINARY-LONG.
 01 WS-H                   BINARY-LONG.
 01 WS-FOUND               BINARY-LONG.
 01 WS-CAPACITY            BINARY-LONG VALUE 262144.
 01 WS-PATH                PIC X(256).
 01 WS-PATH-LENGTH         BINARY-LONG.
 01 WS-FROM                BINARY-LONG.
 01 WS-TO                  BINARY-LONG.
 01 WS-ROW-BYTES           BINARY-LONG.
 01 WS-SAME                BINARY-LONG.
 01 WS-TEXEL-V             FLOAT-LONG.
 01 WS-IN-SLOT             BINARY-LONG.
 01 WS-N                   BINARY-LONG.
 01 WS-CODE                BINARY-LONG.
 01 WS-MD                  BINARY-LONG.
 01 WS-MISSING             BINARY-LONG.
 01 WS-IMG                 PIC X(262144).
 01 B-ATLAS                PIC X(16777216) BASED.
*> The variant of each case (-1 none) and the file name it must show.
 01 WS-VARIANT-DATA.
    05 FILLER PIC X(20) VALUE "-001brown           ".
    05 FILLER PIC X(20) VALUE "+000brown           ".
    05 FILLER PIC X(20) VALUE "+001white           ".
    05 FILLER PIC X(20) VALUE "+002black           ".
    05 FILLER PIC X(20) VALUE "+003white_splotched ".
    05 FILLER PIC X(20) VALUE "+004gold            ".
    05 FILLER PIC X(20) VALUE "+005salt            ".
    05 FILLER PIC X(20) VALUE "+099caerbannog      ".
    05 FILLER PIC X(20) VALUE "+100toast           ".
    05 FILLER PIC X(20) VALUE "+101toast           ".
 01 WS-VARIANTS REDEFINES WS-VARIANT-DATA.
    05 WS-VAR-ROW OCCURS 10 TIMES.
       10 WS-VAR-ID          PIC S999 SIGN LEADING SEPARATE.
       10 WS-VAR-NAME        PIC X(16).
 01 WS-ROW                BINARY-LONG VALUE 1.
 01 WS-NAME-INDEX          BINARY-LONG VALUE 2.
 01 WS-NAME-SERIAL         BINARY-LONG VALUE 6.
 01 WS-PRESENT             PIC 9 VALUE 1.
 01 WS-DATA-LENGTH         BINARY-LONG VALUE 8.
 01 WS-NAME-STRING         PIC X(512).
 01 WS-NAME-COMPOUND       PIC X(512).
 01 WS-EYE-TABLE.
    05 WS-EYE              FLOAT-LONG OCCURS 3 TIMES.
 PROCEDURE DIVISION.
     MOVE SPACES TO WS-GEN
     ACCEPT WS-GEN FROM ENVIRONMENT "CC_GENERATED_DIR"
     IF WS-GEN = SPACES
         MOVE "/tmp/cc-test/generated" TO WS-GEN
     END-IF
     MOVE SPACES TO WS-ROOT
     STRING FUNCTION TRIM(WS-GEN) "/vanilla-resources" DELIMITED BY SIZE INTO WS-ROOT
     CALL "CL-INIT" USING CLIENT-STATE
     CALL "PACK-STACK-INIT" USING CLIENT-STATE
     ADD 1 TO PK-COUNT
     INITIALIZE PK-PACK(PK-COUNT)
     MOVE 1 TO PK-KIND(PK-COUNT)
     MOVE 3 TO PK-LEVEL(PK-COUNT)
     MOVE "generated/vanilla" TO PK-ID(PK-COUNT)
     MOVE 17 TO PK-ID-LENGTH(PK-COUNT)
     MOVE WS-ROOT TO PK-ROOT(PK-COUNT)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-ROOT)) TO PK-ROOT-LENGTH(PK-COUNT)
     CALL "PACK-STACK-OPEN" USING CLIENT-STATE
     CALL "PACK-SOURCE-FILES" USING CLIENT-STATE PK-COUNT
     CALL "ATLAS-BUILD" USING CLIENT-STATE
     MOVE 256 TO PL-HEIGHT
     MOVE 0 TO SK-U
     MOVE CT-TYPE-STANDARD TO CT-SET-TYPE
     CALL "CONTENT-SET-COUNTS"
     MOVE 1 TO CT-OPEN
     MOVE 10 TO WS-EYE(1) WS-EYE(3)
     MOVE 64 TO WS-EYE(2)
     MOVE SPACES TO WS-KEY
     MOVE "rabbit" TO WS-KEY
     CALL "CONTENT-ENTITY-BY-KEY" USING WS-KEY WS-TYPE WS-ROW-AREA WS-STATUS
     MOVE "N" TO TL-MODE
     MOVE 0 TO WS-N
     MOVE LOW-VALUES TO WS-NAME-STRING WS-NAME-COMPOUND
*>   String tag: type 8, length 5, "Toast". Compound: type 10, string tag "text" = "Toast", end.
     MOVE FUNCTION CHAR(9) TO WS-NAME-STRING(1:1)
     MOVE FUNCTION CHAR(6) TO WS-NAME-STRING(3:1)
     MOVE "Toast" TO WS-NAME-STRING(4:5)
     MOVE FUNCTION CHAR(11) TO WS-NAME-COMPOUND(1:1)
     MOVE FUNCTION CHAR(9) TO WS-NAME-COMPOUND(2:1)
     MOVE FUNCTION CHAR(5) TO WS-NAME-COMPOUND(4:1)
     MOVE "text" TO WS-NAME-COMPOUND(5:4)
     MOVE FUNCTION CHAR(6) TO WS-NAME-COMPOUND(10:1)
     MOVE "Toast" TO WS-NAME-COMPOUND(11:5)
     PERFORM VARYING WS-CASE FROM 1 BY 1 UNTIL WS-CASE > 20
         COMPUTE WS-BABY = FUNCTION INTEGER((WS-CASE - 1) / 10)
         COMPUTE WS-R = WS-CASE - WS-BABY * 10
         MOVE WS-VAR-ID(WS-R) TO WS-V
         MOVE WS-CASE TO WS-CASE-D
         CALL "ENTITIES-CLEAR" USING CLIENT-STATE
         MOVE 0 TO EA-MT-COUNT
         CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
         EVALUATE TRUE
             WHEN WS-V = 100
*>               A rabbit of variant 3 named Toast (custom name entry 2, OPTIONAL_COMPONENT, a string tag): the toast skin wins.
                 MOVE 3 TO EN-VAR(1)
                 MOVE 8 TO WS-DATA-LENGTH
                 CALL "ENTITY-NAME-SET" USING CLIENT-STATE WS-ROW WS-NAME-INDEX WS-NAME-SERIAL WS-PRESENT WS-DATA-LENGTH WS-NAME-STRING
             WHEN WS-V = 101
*>               The same name as a compound {text: "Toast"}, no variant entry.
                 MOVE 16 TO WS-DATA-LENGTH
                 CALL "ENTITY-NAME-SET" USING CLIENT-STATE WS-ROW WS-NAME-INDEX WS-NAME-SERIAL WS-PRESENT WS-DATA-LENGTH WS-NAME-COMPOUND
             WHEN WS-V >= 0
                 MOVE WS-V TO EN-VAR(1)
             WHEN OTHER
                 CONTINUE
         END-EVALUATE
         MOVE WS-BABY TO EN-BABY(1)
         CALL "ENTITIES-MESH" USING CLIENT-STATE WS-EYE-TABLE
*>       The pack's image of the file the variant names.
         MOVE SPACES TO WS-PATH
         IF WS-BABY = 0
             STRING "assets/minecraft/textures/entity/rabbit/rabbit_" FUNCTION TRIM(WS-VAR-NAME(WS-R)) ".png"
                 DELIMITED BY SIZE INTO WS-PATH
         ELSE
             STRING "assets/minecraft/textures/entity/rabbit/rabbit_" FUNCTION TRIM(WS-VAR-NAME(WS-R)) "_baby.png"
                 DELIMITED BY SIZE INTO WS-PATH
         END-IF
         MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
         CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMG WS-CAPACITY WS-W WS-H WS-FOUND
         MOVE SPACES TO TL-CASE
         STRING "acceptance rabbit skin the pack has " FUNCTION TRIM(WS-PATH) DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-FOUND TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         MOVE SPACES TO TL-CASE
         STRING "acceptance rabbit skin one slot for case " WS-CASE-D DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE EA-MT-COUNT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>       The slot's atlas rows equal the pack image, row by row.
         SET ADDRESS OF B-ATLAS TO EA-ADDR
         MOVE 1 TO WS-SAME
         IF EA-MT-W(1) NOT = WS-W OR EA-MT-H(1) NOT = WS-H
             MOVE 0 TO WS-SAME
         END-IF
         COMPUTE WS-ROW-BYTES = WS-W * 4
         PERFORM VARYING WS-R FROM 0 BY 1 UNTIL WS-R >= WS-H OR WS-SAME = 0
             COMPUTE WS-TO = (EA-MT-Y(1) + WS-R) * EA-W * 4 + 1
             COMPUTE WS-FROM = WS-R * WS-ROW-BYTES + 1
             IF B-ATLAS(WS-TO:WS-ROW-BYTES) NOT = WS-IMG(WS-FROM:WS-ROW-BYTES)
                 MOVE 0 TO WS-SAME
             END-IF
         END-PERFORM
         MOVE SPACES TO TL-CASE
         STRING "acceptance rabbit skin the slot holds the pack image, case " WS-CASE-D DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-SAME TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
         ADD WS-SAME TO WS-N
*>       The first vertex takes its v from inside the slot.
         COMPUTE WS-TEXEL-V = RL-EN-V(1) * EA-H
         MOVE 0 TO WS-IN-SLOT
         IF RL-EN-COUNT > 0 AND WS-TEXEL-V >= EA-MT-Y(1) AND WS-TEXEL-V <= EA-MT-Y(1) + EA-MT-H(1)
             MOVE 1 TO WS-IN-SLOT
         END-IF
         MOVE SPACES TO TL-CASE
         STRING "acceptance rabbit skin the vertices read the slot, case " WS-CASE-D DELIMITED BY SIZE INTO TL-CASE
         MOVE 1 TO TL-EXPECTED-N
         MOVE WS-IN-SLOT TO TL-OBSERVED-N
         CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     END-PERFORM
     MOVE "acceptance rabbit skin all 20 adult and baby rabbits show the pack image" TO TL-CASE
     MOVE 20 TO TL-EXPECTED-N
     MOVE WS-N TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Names that are not Toast: "Toasty" (string, length 6), the name removed (not present), the wrong entry (3), and another type's entry 2.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE FUNCTION CHAR(7) TO WS-NAME-STRING(3:1)
     MOVE "Toasty" TO WS-NAME-STRING(4:6)
     MOVE 9 TO WS-DATA-LENGTH
     CALL "ENTITY-NAME-SET" USING CLIENT-STATE WS-ROW WS-NAME-INDEX WS-NAME-SERIAL WS-PRESENT WS-DATA-LENGTH WS-NAME-STRING
     MOVE "acceptance rabbit skin the name Toasty is not the toast skin" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE FUNCTION CHAR(6) TO WS-NAME-STRING(3:1)
     MOVE 3 TO WS-NAME-INDEX
     MOVE 8 TO WS-DATA-LENGTH
     CALL "ENTITY-NAME-SET" USING CLIENT-STATE WS-ROW WS-NAME-INDEX WS-NAME-SERIAL WS-PRESENT WS-DATA-LENGTH WS-NAME-STRING
     MOVE "acceptance rabbit skin entry 3 is not the custom name" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 2 TO WS-NAME-INDEX
     CALL "ENTITY-NAME-SET" USING CLIENT-STATE WS-ROW WS-NAME-INDEX WS-NAME-SERIAL WS-PRESENT WS-DATA-LENGTH WS-NAME-STRING
     MOVE "acceptance rabbit skin the name Toast sets the toast flag" TO TL-CASE
     MOVE 1 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-PRESENT
     CALL "ENTITY-NAME-SET" USING CLIENT-STATE WS-ROW WS-NAME-INDEX WS-NAME-SERIAL WS-PRESENT WS-DATA-LENGTH WS-NAME-STRING
     MOVE "acceptance rabbit skin removing the name ends the toast skin" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 1 TO WS-PRESENT
     MOVE "cow" TO EN-KEY(1)
     CALL "ENTITY-NAME-SET" USING CLIENT-STATE WS-ROW WS-NAME-INDEX WS-NAME-SERIAL WS-PRESENT WS-DATA-LENGTH WS-NAME-STRING
     MOVE "acceptance rabbit skin a cow named Toast keeps its own skin" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE EN-X1(1) TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Through a real Set Entity Data packet (101): the rabbit's entry 2 with the name Toast gives texture code 9, the same entry with another name takes it away.
     CALL "ENTITIES-CLEAR" USING CLIENT-STATE
     CALL "MM-SPAWN" USING CLIENT-STATE WS-ID WS-TYPE WS-X WS-Y WS-Z WS-YAW
     MOVE 1 TO WS-PRESENT
     MOVE 8 TO WS-DATA-LENGTH
     MOVE FUNCTION CHAR(6) TO WS-NAME-STRING(3:1)
     MOVE "Toast" TO WS-NAME-STRING(4:5)
     CALL "RS-DATA" USING CLIENT-STATE WS-ID WS-PRESENT WS-DATA-LENGTH WS-NAME-STRING
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE WS-ROW EN-MODEL(1) WS-CODE
     MOVE "acceptance rabbit skin a Set Entity Data name Toast is texture code 9" TO TL-CASE
     MOVE 9 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     MOVE 0 TO WS-PRESENT
     MOVE 0 TO WS-DATA-LENGTH
     CALL "RS-DATA" USING CLIENT-STATE WS-ID WS-PRESENT WS-DATA-LENGTH WS-NAME-STRING
     CALL "ENTITY-TEX-CODE" USING CLIENT-STATE WS-ROW EN-MODEL(1) WS-CODE
     MOVE "acceptance rabbit skin a Set Entity Data without the name is texture code 0" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-CODE TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
*>   Every model row that names an image has it in the pack (a row whose own path no pack has draws the stripes when no variant is known).
     MOVE 0 TO WS-MISSING
     PERFORM VARYING WS-MD FROM 1 BY 1 UNTIL WS-MD > CL-MODEL-COUNT
         IF CL-MD-PATH(WS-MD) NOT = SPACES
             MOVE SPACES TO WS-PATH
             STRING "assets/minecraft/" DELIMITED BY SIZE FUNCTION TRIM(CL-MD-PATH(WS-MD)) DELIMITED BY SIZE INTO WS-PATH
             MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-PATH)) TO WS-PATH-LENGTH
             CALL "PACK-IMAGE" USING CLIENT-STATE WS-PATH WS-PATH-LENGTH WS-IMG WS-CAPACITY WS-W WS-H WS-FOUND
             IF WS-FOUND = 0
                 ADD 1 TO WS-MISSING
                 DISPLAY "missing model image " FUNCTION TRIM(CL-MD-PATH(WS-MD))
             END-IF
         END-IF
     END-PERFORM
     MOVE "acceptance rabbit skin every model row's own image is in the real pack" TO TL-CASE
     MOVE 0 TO TL-EXPECTED-N
     MOVE WS-MISSING TO TL-OBSERVED-N
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT
     GOBACK.
 END PROGRAM TEST-ENTITY-RABBIT-SKIN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. MM-SPAWN.
*> USING CLIENT-STATE, entity id, type (registry id), x y z (FLOAT-LONG), yaw (FLOAT-SHORT, also the head yaw): Add Entity.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-ADD                 BINARY-LONG VALUE 1.
 01 WS-ZERO                BINARY-LONG VALUE 0.
 01 WS-UUID                PIC X(16) VALUE LOW-VALUES.
 01 WS-V0                  FLOAT-LONG VALUE 0.
 01 WS-V1                  FLOAT-LONG VALUE 0.
 01 WS-V2                  FLOAT-LONG VALUE 0.
 01 WS-A0                  FLOAT-SHORT VALUE 0.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-TYPE                 BINARY-LONG.
 01 L-X                    FLOAT-LONG.
 01 L-Y                    FLOAT-LONG.
 01 L-Z                    FLOAT-LONG.
 01 L-YAW                  FLOAT-SHORT.
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-TYPE L-X L-Y L-Z L-YAW.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     CALL "PB-PUT-UUID" USING PB-BUFFER WS-UUID
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-TYPE
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-X
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Y
     CALL "PB-PUT-DOUBLE" USING PB-BUFFER L-Z
     CALL "PB-PUT-LPVEC3" USING PB-BUFFER WS-V0 WS-V1 WS-V2
     CALL "PB-PUT-ANGLE" USING PB-BUFFER WS-A0
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-ANGLE" USING PB-BUFFER L-YAW
     CALL "PB-PUT-VARINT" USING PB-BUFFER WS-ZERO
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-ADD
     GOBACK.
 END PROGRAM MM-SPAWN.

 IDENTIFICATION DIVISION.
 PROGRAM-ID. RS-DATA.
*> USING CLIENT-STATE, entity id, present (PIC 9), data length, data: Set Entity Data with the custom name entry (index 2, OPTIONAL_COMPONENT) only.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY PROTO.
 COPY PROTO REPLACING LEADING ==PB-== BY ==MD-==.
 01 WS-READY               BINARY-LONG VALUE 0.
 01 WS-CAPACITY            BINARY-LONG VALUE 1024.
 01 WS-DATA                BINARY-LONG VALUE 101.
 LINKAGE SECTION.
 COPY CLSTATE.
 01 L-ID                   BINARY-LONG.
 01 L-PRESENT              PIC 9.
 01 L-LENGTH               BINARY-LONG.
 01 L-DATA                 PIC X(512).
 PROCEDURE DIVISION USING CLIENT-STATE L-ID L-PRESENT L-LENGTH L-DATA.
     IF WS-READY = 0
         CALL "PB-INIT" USING PB-BUFFER WS-CAPACITY
         MOVE 1 TO WS-READY
     END-IF
     CALL "PB-RESET" USING PB-BUFFER
     CALL "PB-PUT-VARINT" USING PB-BUFFER L-ID
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE 2 TO MD-MX-INDEX
     MOVE 6 TO MD-MX-SERIALIZER
     MOVE L-PRESENT TO MD-MX-PRESENT
     MOVE L-LENGTH TO MD-MX-DATA-LENGTH
     MOVE L-DATA TO MD-MX-DATA
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     INITIALIZE MD-METADATA-ENTRY-X
     MOVE MD-MD-END TO MD-MX-INDEX
     CALL "PB-PUT-METADATA-ENTRY-X" USING PB-BUFFER MD-METADATA-ENTRY-X
     MOVE 0 TO PB-POS
     CALL "ENTITY-PACKET" USING CLIENT-STATE PB-BUFFER WS-DATA
     GOBACK.
 END PROGRAM RS-DATA.

 COPY CLTEST.
