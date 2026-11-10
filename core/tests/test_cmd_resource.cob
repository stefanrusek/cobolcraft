*> Acceptance test of the registry lookup of resource arguments (docs/protocol/15-commands-framework.md §6.7; core/src/cmd-types.cob
*> CHECK-REGISTRY over the content API CONTENT-REGISTRY-COUNT and -ENTRY): an identifier read for a resource (46) or resource or tag (44)
*> argument whose node holds a registry key (BR-N-REG) must be an entry of that registry of the open content set (without a namespace
*> it is in the namespace of the set: cobolcraft: here), else argument.resource.not_found [identifier, registry] with the cursor at the
*> identifier; a tag (#) is not looked up, a registry the set does not hold is not checked, a node without a registry key either.
*> rs: resource of minecraft:entity_type, rt: of a registry the set does not hold, ro: resource or tag of entity_type, rr: no registry key.
 IDENTIFICATION DIVISION.
 PROGRAM-ID. TEST-CMD-RESOURCE.
 DATA DIVISION.
 WORKING-STORAGE SECTION.
 COPY TESTLIB.
 COPY BRIGADIER.
 COPY BRTRAIL REPLACING LEADING ==BT-== BY ==RS-==.
 COPY COREAPI.
 01 WS-CASES.
    05 FILLER PIC X(60) VALUE "rs cobolcraft:sodgrazer$".
    05 FILLER PIC X(120) VALUE "ok".
    05 FILLER PIC X(60) VALUE "rs sodgrazer$".
    05 FILLER PIC X(120) VALUE "ok".
    05 FILLER PIC X(60) VALUE "rs cobolcraft:abend$".
    05 FILLER PIC X(120) VALUE "ok".
    05 FILLER PIC X(60) VALUE "rs cobolcraft:nothing$".
    05 FILLER PIC X(120) VALUE "err argument.resource.not_found|cobolcraft:nothing|minecraft:entity_type@3".
    05 FILLER PIC X(60) VALUE "rs nothing$".
    05 FILLER PIC X(120) VALUE "err argument.resource.not_found|cobolcraft:nothing|minecraft:entity_type@3".
    05 FILLER PIC X(60) VALUE "rs minecraft:zombie$".
    05 FILLER PIC X(120) VALUE "err argument.resource.not_found|minecraft:zombie|minecraft:entity_type@3".
    05 FILLER PIC X(60) VALUE "rt cobolcraft:anything$".
    05 FILLER PIC X(120) VALUE "ok".
    05 FILLER PIC X(60) VALUE "ro #foo:bar$".
    05 FILLER PIC X(120) VALUE "ok".
    05 FILLER PIC X(60) VALUE "ro sodgrazer$".
    05 FILLER PIC X(120) VALUE "ok".
    05 FILLER PIC X(60) VALUE "ro nothing$".
    05 FILLER PIC X(120) VALUE "err argument.resource.not_found|cobolcraft:nothing|minecraft:entity_type@3".
    05 FILLER PIC X(60) VALUE "rr nothing$".
    05 FILLER PIC X(120) VALUE "ok".
 01 WS-TABLE REDEFINES WS-CASES.
    05 WS-CASE OCCURS 11 TIMES.
       10 WS-CASE-LINE PIC X(60).
       10 WS-CASE-EXPECTED PIC X(120).

 01 WS-LINE                PIC X(1024).
 01 WS-LENGTH              BINARY-LONG.
 01 WS-LEVEL               BINARY-LONG VALUE 4.
 01 WS-VERDICT             BINARY-LONG.
 01 WS-COMMAND             BINARY-LONG.
 01 WS-TEXT                PIC X(200).
 01 WS-POS                 BINARY-LONG.
 01 WS-I                   BINARY-LONG.
 01 WS-E                   BINARY-LONG.
 01 WS-EDIT                PIC -(9)9.
 01 WS-NODE                BINARY-LONG.
 01 WS-CHILD               BINARY-LONG.
 01 WS-CREATED             BINARY-LONG.
 01 WS-NAME                PIC X(32).
 01 WS-NAME-LENGTH         BINARY-LONG.
 01 WS-KIND                BINARY-LONG.
 01 WS-TYPE                BINARY-LONG.
 01 WS-TYPES.
    05 FILLER PIC X(4) VALUE "rs".
    05 FILLER PIC S9(9) BINARY VALUE 46.
    05 FILLER PIC X(40) VALUE "minecraft:entity_type".
    05 FILLER PIC X(4) VALUE "rt".
    05 FILLER PIC S9(9) BINARY VALUE 46.
    05 FILLER PIC X(40) VALUE "minecraft:no_such_registry".
    05 FILLER PIC X(4) VALUE "ro".
    05 FILLER PIC S9(9) BINARY VALUE 44.
    05 FILLER PIC X(40) VALUE "minecraft:entity_type".
    05 FILLER PIC X(4) VALUE "rr".
    05 FILLER PIC S9(9) BINARY VALUE 46.
    05 FILLER PIC X(40) VALUE SPACES.
 01 WS-TYPE-TABLE REDEFINES WS-TYPES.
    05 WS-T OCCURS 4 TIMES.
       10 WS-T-LIT PIC X(4).
       10 WS-T-ID PIC S9(9) BINARY.
       10 WS-T-REG PIC X(40).
 PROCEDURE DIVISION.
     CALL "TEST-SETTINGS" USING CORE-SETTINGS
     CALL "TEST-OPEN-WORLD" USING CORE-SETTINGS
     CALL "BR-TREE-RESET"
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 4
         PERFORM ADD-TYPE
     END-PERFORM
     PERFORM VARYING WS-I FROM 1 BY 1 UNTIL WS-I > 11
         MOVE WS-CASE-LINE(WS-I) TO WS-LINE
         PERFORM CHECK
     END-PERFORM
     GOBACK.

 ADD-TYPE.
     MOVE 1 TO WS-NODE
     MOVE BR-LITERAL TO WS-KIND
     MOVE 0 TO WS-TYPE
     MOVE WS-T-LIT(WS-I) TO WS-NAME
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-NAME)) TO WS-NAME-LENGTH
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE WS-CHILD TO WS-NODE
     MOVE BR-ARGUMENT TO WS-KIND
     MOVE "v" TO WS-NAME
     MOVE 1 TO WS-NAME-LENGTH
     MOVE WS-T-ID(WS-I) TO WS-TYPE
     CALL "BR-ADD-NODE" USING WS-NODE WS-KIND WS-NAME WS-NAME-LENGTH WS-TYPE WS-CHILD WS-CREATED
     MOVE WS-I TO BR-N-COMMAND(WS-CHILD)
     MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-T-REG(WS-I))) TO BR-N-REG-LENGTH(WS-CHILD)
     IF WS-T-REG(WS-I) = SPACES
         MOVE 0 TO BR-N-REG-LENGTH(WS-CHILD)
     END-IF
     MOVE WS-T-REG(WS-I) TO BR-N-REG(WS-CHILD).

 CHECK.
     MOVE 0 TO WS-LENGTH
     INSPECT WS-LINE TALLYING WS-LENGTH FOR CHARACTERS BEFORE INITIAL "$"
     MOVE SPACE TO WS-LINE(WS-LENGTH + 1:1)
     CALL "BR-PARSE" USING WS-LEVEL WS-LINE WS-LENGTH RS-TRAIL
     CALL "BR-VERDICT" USING RS-TRAIL WS-VERDICT WS-COMMAND
     MOVE SPACES TO WS-TEXT
     MOVE 1 TO WS-POS
     IF WS-VERDICT = 0
         MOVE "ok" TO WS-TEXT
     ELSE
         STRING "err " FUNCTION TRIM(BR-E-KEY) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         PERFORM VARYING WS-E FROM 1 BY 1 UNTIL WS-E > BR-E-ARG-COUNT
             STRING "|" BR-E-ARG(WS-E)(1:BR-E-ARG-LENGTH(WS-E)) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
         END-PERFORM
         MOVE BR-E-CURSOR TO WS-EDIT
         STRING "@" FUNCTION TRIM(WS-EDIT) DELIMITED BY SIZE INTO WS-TEXT WITH POINTER WS-POS
     END-IF
     MOVE SPACES TO TL-CASE
     STRING "acceptance US13 15§6 Argument types resource lookup [" WS-LINE(1:WS-LENGTH) "]" DELIMITED BY SIZE INTO TL-CASE
     MOVE "T" TO TL-MODE
     MOVE WS-CASE-EXPECTED(WS-I) TO TL-EXPECTED
     MOVE WS-TEXT TO TL-OBSERVED
     CALL "TEST-ASSERT" USING TESTLIB-ASSERT.

 END PROGRAM TEST-CMD-RESOURCE.

 COPY CORETEST.

